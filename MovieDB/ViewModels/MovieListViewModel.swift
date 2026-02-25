//  Created by Aji Prakosa on 25 February 2026.

import SwiftUI

@MainActor
final class MovieListViewModel: ObservableObject {
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var isLoading = false
    @Published var error: AppError?
    @Published private(set) var hasMoreData = true

    private(set) var currentPage = 1
    private let repository: MovieRepositoryProtocol

    init(repository: MovieRepositoryProtocol = MovieRepository()) {
        self.repository = repository
    }

    func fetchMovies(isRefreshing: Bool = false) {
        guard !isLoading else { return }
        if isRefreshing {
            currentPage = 1
            hasMoreData = true
        }
        guard hasMoreData else { return }
        isLoading = true
        error = nil

        Task {
            do {
                let response = try await repository.fetchMovies(page: currentPage)
                if isRefreshing { movies = response.results }
                else { movies += response.results }
                currentPage += 1
                hasMoreData = currentPage <= response.totalPagesCount
            } catch let err as AppError {
                self.error = err
            } catch {
                self.error = AppError.from(error)
            }
            isLoading = false
        }
    }

    func loadMoreMoviesIfNeeded(currentItem item: Movie?) {
        guard let item = item else {
            fetchMovies()
            return
        }
        let thresholdIndex = movies.index(movies.endIndex, offsetBy: -5)
        if movies.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            fetchMovies()
        }
    }
}
