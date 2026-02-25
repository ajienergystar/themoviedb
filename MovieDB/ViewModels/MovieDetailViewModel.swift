//  Created by Aji Prakosa on 25 February 2026.

import SwiftUI

@MainActor
final class MovieDetailViewModel: ObservableObject {
    @Published private(set) var movieDetail: MovieDetail?
    @Published private(set) var reviews: [Review] = []
    @Published private(set) var videos: [Video] = []
    @Published private(set) var isLoading = false
    @Published var error: AppError?

    private let repository: MovieRepositoryProtocol
    private(set) var movieId: Int

    init(movieId: Int, repository: MovieRepositoryProtocol = MovieRepository()) {
        self.repository = repository
        self.movieId = movieId
        fetchMovieDetails(movieId: movieId)
    }

    func fetchMovieDetails(movieId: Int) {
        isLoading = true
        error = nil
        Task {
            do {
                let (detail, reviewsResult, videosResult) = try await repository.fetchMovieDetailWithExtras(movieId: movieId)
                movieDetail = detail
                reviews = reviewsResult
                videos = videosResult
            } catch let err as AppError {
                self.error = err
            } catch {
                self.error = AppError.from(error)
            }
            isLoading = false
        }
    }

    var youtubeTrailer: Video? {
        videos.first { $0.site == "YouTube" && $0.type == "Trailer" }
    }
}
