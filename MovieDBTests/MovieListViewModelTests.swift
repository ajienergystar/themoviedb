//  Created by Aji Prakosa on 25 February 2026.

import XCTest
@testable import MovieDB

@MainActor
class MovieListViewModelTests: XCTestCase {
    var viewModel: MovieListViewModel!
    var mockRepository: MockMovieRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockMovieRepository()
        viewModel = MovieListViewModel(repository: mockRepository)
    }

    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }

    func testFetchMoviesSuccess() async {
        let mockMovies = [
            Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/poster1.jpg", backdropPath: "/backdrop1.jpg", voteAverage: 8.0, releaseDate: "2023-01-01"),
            Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/poster2.jpg", backdropPath: "/backdrop2.jpg", voteAverage: 7.5, releaseDate: "2023-01-02")
        ]
        mockRepository.mockMovieResponse = MovieResponse(page: 1, results: mockMovies, totalPages: 1, totalResults: 2)

        viewModel.fetchMovies()

        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.movies.count, 2)
        XCTAssertEqual(viewModel.movies[0].title, "Movie 1")
        XCTAssertEqual(viewModel.movies[1].title, "Movie 2")
        XCTAssertNil(viewModel.error)
    }

    func testFetchMoviesFailure() async {
        mockRepository.shouldFail = true
        viewModel.fetchMovies()

        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.movies.isEmpty)
        XCTAssertNotNil(viewModel.error)
    }

    func testLoadMoreMovies() async {
        let mockMoviesPage1 = [Movie(id: 1, title: "Movie 1", overview: "Overview 1", posterPath: "/poster1.jpg", backdropPath: "/backdrop1.jpg", voteAverage: 8.0, releaseDate: "2023-01-01")]
        let mockMoviesPage2 = [Movie(id: 2, title: "Movie 2", overview: "Overview 2", posterPath: "/poster2.jpg", backdropPath: "/backdrop2.jpg", voteAverage: 7.5, releaseDate: "2023-01-02")]
        mockRepository.mockMovieResponse = MovieResponse(page: 1, results: mockMoviesPage1, totalPages: 2, totalResults: 2)

        viewModel.fetchMovies()
        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(viewModel.movies.count, 1)
        XCTAssertEqual(viewModel.currentPage, 2)
        XCTAssertTrue(viewModel.hasMoreData)

        mockRepository.mockMovieResponse = MovieResponse(page: 2, results: mockMoviesPage2, totalPages: 2, totalResults: 2)
        viewModel.loadMoreMoviesIfNeeded(currentItem: viewModel.movies.last)
        try? await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(viewModel.movies.count, 2)
        XCTAssertEqual(viewModel.currentPage, 3)
        XCTAssertFalse(viewModel.hasMoreData)
    }
}

final class MockMovieRepository: MovieRepositoryProtocol {
    var mockMovieResponse: MovieResponse!
    var shouldFail = false

    func fetchMovies(page: Int) async throws -> MovieResponse {
        if shouldFail { throw NetworkError.invalidResponse }
        return mockMovieResponse
    }

    func fetchMovieDetail(movieId: Int) async throws -> MovieDetail {
        throw NetworkError.invalidResponse
    }

    func fetchMovieReviews(movieId: Int) async throws -> [Review] {
        []
    }

    func fetchMovieVideos(movieId: Int) async throws -> [Video] {
        []
    }

    func fetchMovieDetailWithExtras(movieId: Int) async throws -> (detail: MovieDetail, reviews: [Review], videos: [Video]) {
        throw NetworkError.invalidResponse
    }
}


