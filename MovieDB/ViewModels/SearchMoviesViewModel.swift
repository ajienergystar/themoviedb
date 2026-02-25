//
//  SearchMoviesViewModel.swift
//  MovieDB
//

import SwiftUI

@MainActor
final class SearchMoviesViewModel: ObservableObject {
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var isLoading = false
    @Published var error: AppError?
    @Published private(set) var hasMoreData = true

    private(set) var currentPage = 1
    private var lastQuery = ""
    private let repository: MovieRepositoryProtocol

    init(repository: MovieRepositoryProtocol = MovieRepository()) {
        self.repository = repository
    }

    func search(query: String, isNewSearch: Bool = true) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if isNewSearch {
            lastQuery = trimmed
            currentPage = 1
            hasMoreData = true
            if trimmed.isEmpty {
                movies = []
                return
            }
        }
        guard !isLoading, hasMoreData else { return }
        isLoading = true
        error = nil

        Task {
            do {
                let response = try await repository.fetchSearchMovies(query: lastQuery, page: currentPage)
                if isNewSearch { movies = response.results }
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

    func loadMoreIfNeeded(currentItem item: Movie?) {
        guard let item = item, !lastQuery.isEmpty else { return }
        let thresholdIndex = movies.index(movies.endIndex, offsetBy: -5)
        if movies.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            search(query: lastQuery, isNewSearch: false)
        }
    }
}
