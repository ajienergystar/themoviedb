//
//  MovieRepository.swift
//  MovieDB
//

import Foundation
import CoreData

/// Repository yang mengimplementasikan strategi cache-first: baca dari cache lokal dulu, baru API jika perlu.
final class MovieRepository: MovieRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let persistenceController: PersistenceController
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()

    init(
        networkService: NetworkServiceProtocol = NetworkService.shared,
        persistenceController: PersistenceController = .shared
    ) {
        self.networkService = networkService
        self.persistenceController = persistenceController
    }

    func fetchMovies(page: Int) async throws -> MovieResponse {
        if let response = loadCachedMoviePageIfValid(page: page) {
            return response
        }
        let response = try await networkService.fetchMovies(page: page)
        saveMoviePage(response, page: page)
        return response
    }

    func fetchPopularMovies(page: Int) async throws -> MovieResponse {
        let response = try await networkService.fetchPopularMovies(page: page)
        return response
    }

    func fetchSearchMovies(query: String, page: Int) async throws -> MovieResponse {
        let response = try await networkService.fetchSearchMovies(query: query, page: page)
        return response
    }

    func fetchMovieDetail(movieId: Int) async throws -> MovieDetail {
        let (detail, _, _) = try await fetchMovieDetailWithExtras(movieId: movieId)
        return detail
    }

    func fetchMovieReviews(movieId: Int) async throws -> [Review] {
        let (_, reviews, _) = try await fetchMovieDetailWithExtras(movieId: movieId)
        return reviews
    }

    func fetchMovieVideos(movieId: Int) async throws -> [Video] {
        let (_, _, videos) = try await fetchMovieDetailWithExtras(movieId: movieId)
        return videos
    }

    func fetchMovieDetailWithExtras(movieId: Int) async throws -> (detail: MovieDetail, reviews: [Review], videos: [Video]) {
        if let cached = loadCachedMovieDetailIfValid(movieId: movieId) {
            return (cached.detail, cached.reviews, cached.videos)
        }
        async let detail = networkService.fetchMovieDetails(id: movieId)
        async let reviews = networkService.fetchMovieReviews(id: movieId)
        async let videos = networkService.fetchMovieVideos(id: movieId)
        let (movieDetail, reviewResponse, videoResponse) = try await (detail, reviews, videos)
        let cache = MovieDetailCache(detail: movieDetail, reviews: reviewResponse.results, videos: videoResponse.results)
        saveMovieDetail(cache, movieId: movieId)
        return (movieDetail, reviewResponse.results, videoResponse.results)
    }

    // MARK: - Private cache helpers

    private var backgroundContext: NSManagedObjectContext {
        persistenceController.container.newBackgroundContext()
    }

    private func isCacheExpired(savedAt: Date?, expiry: TimeInterval) -> Bool {
        guard let savedAt = savedAt else { return true }
        return Date().timeIntervalSince(savedAt) > expiry
    }

    private func loadCachedMoviePageIfValid(page: Int) -> MovieResponse? {
        let context = backgroundContext
        var result: MovieResponse?
        context.performAndWait {
            let request = CachedMoviePage.fetchRequest()
            request.predicate = NSPredicate(format: "page == %d", page)
            request.fetchLimit = 1
            guard let cached = try? context.fetch(request).first,
                  !isCacheExpired(savedAt: cached.savedAt, expiry: CacheConstants.movieListExpiryInterval),
                  let data = cached.jsonData else { return }
            result = try? decoder.decode(MovieResponse.self, from: data)
        }
        return result
    }

    private func loadCachedMovieDetailIfValid(movieId: Int) -> MovieDetailCache? {
        let context = backgroundContext
        var result: MovieDetailCache?
        context.performAndWait {
            let request = CachedMovieDetail.fetchRequest()
            request.predicate = NSPredicate(format: "movieId == %d", movieId)
            request.fetchLimit = 1
            guard let cached = try? context.fetch(request).first,
                  !isCacheExpired(savedAt: cached.savedAt, expiry: CacheConstants.movieDetailExpiryInterval),
                  let data = cached.jsonData else { return }
            result = try? decoder.decode(MovieDetailCache.self, from: data)
        }
        return result
    }

    private func saveMoviePage(_ response: MovieResponse, page: Int) {
        let context = backgroundContext
        context.performAndWait {
            let request = CachedMoviePage.fetchRequest()
            request.predicate = NSPredicate(format: "page == %d", page)
            if let existing = try? context.fetch(request).first { context.delete(existing) }
            let cached = CachedMoviePage(context: context)
            cached.page = Int32(page)
            cached.savedAt = Date()
            cached.jsonData = try? encoder.encode(response)
            try? context.save()
        }
    }

    private func saveMovieDetail(_ cache: MovieDetailCache, movieId: Int) {
        let context = backgroundContext
        context.performAndWait {
            let request = CachedMovieDetail.fetchRequest()
            request.predicate = NSPredicate(format: "movieId == %d", movieId)
            if let existing = try? context.fetch(request).first { context.delete(existing) }
            let cached = CachedMovieDetail(context: context)
            cached.movieId = Int32(movieId)
            cached.savedAt = Date()
            cached.jsonData = try? encoder.encode(cache)
            try? context.save()
        }
    }
}
