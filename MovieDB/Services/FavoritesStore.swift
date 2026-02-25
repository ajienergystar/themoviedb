//
//  FavoritesStore.swift
//  MovieDB
//

import Foundation
import CoreData

/// Manages favorite movies in Core Data.
final class FavoritesStore: ObservableObject {
    static let shared = FavoritesStore()
    private let persistenceController: PersistenceController

    @Published private(set) var favorites: [FavoriteMovieItem] = []

    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        loadFavorites()
    }

    var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }

    func loadFavorites() {
        favorites = fetchAllFavorites()
    }

    func isFavorite(movieId: Int) -> Bool {
        let request = FavoriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "movieId == %d", movieId)
        request.fetchLimit = 1
        return (try? viewContext.count(for: request)) == 1
    }

    func addFavorite(movie: Movie) {
        let request = FavoriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "movieId == %d", movie.id)
        request.fetchLimit = 1
        guard (try? viewContext.fetch(request).first) == nil else { return }
        let fav = FavoriteMovie(context: viewContext)
        fav.movieId = Int32(movie.id)
        fav.title = movie.title
        fav.posterPath = movie.posterPath
        fav.releaseDate = movie.releaseDate
        fav.voteAverage = movie.voteAverage ?? 0
        fav.addedAt = Date()
        try? viewContext.save()
        loadFavorites()
    }

    func addFavorite(detail: MovieDetail) {
        let request = FavoriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "movieId == %d", detail.id)
        request.fetchLimit = 1
        guard (try? viewContext.fetch(request).first) == nil else { return }
        let fav = FavoriteMovie(context: viewContext)
        fav.movieId = Int32(detail.id)
        fav.title = detail.title
        fav.posterPath = detail.posterPath
        fav.releaseDate = detail.releaseDate
        fav.voteAverage = detail.voteAverage ?? 0
        fav.addedAt = Date()
        try? viewContext.save()
        loadFavorites()
    }

    func removeFavorite(movieId: Int) {
        let request = FavoriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "movieId == %d", movieId)
        request.fetchLimit = 1
        guard let existing = try? viewContext.fetch(request).first else { return }
        viewContext.delete(existing)
        try? viewContext.save()
        loadFavorites()
    }

    func toggleFavorite(movie: Movie) {
        if isFavorite(movieId: movie.id) {
            removeFavorite(movieId: movie.id)
        } else {
            addFavorite(movie: movie)
        }
    }

    func toggleFavorite(detail: MovieDetail) {
        if isFavorite(movieId: detail.id) {
            removeFavorite(movieId: detail.id)
        } else {
            addFavorite(detail: detail)
        }
    }

    func fetchAllFavorites() -> [FavoriteMovieItem] {
        let request = FavoriteMovie.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FavoriteMovie.addedAt, ascending: false)]
        guard let list = try? viewContext.fetch(request) else { return [] }
        return list.map { FavoriteMovieItem(from: $0) }
    }
}

/// Lightweight model for displaying a favorite in the list.
struct FavoriteMovieItem: Identifiable {
    let id: Int
    let title: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let addedAt: Date?

    init(from fav: FavoriteMovie) {
        id = Int(fav.movieId)
        title = fav.title ?? ""
        posterPath = fav.posterPath
        releaseDate = fav.releaseDate
        voteAverage = fav.voteAverage
        addedAt = fav.addedAt
    }

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: Constants.imageBaseURL + path)
    }

    var ratingText: String { String(format: "%.1f", voteAverage) }

    var formattedReleaseDate: String {
        guard let releaseDate = releaseDate else { return "TBA" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: releaseDate) else { return releaseDate }
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
