//
//  MovieRepositoryProtocol.swift
//  MovieDB
//

import Foundation

/// Protokol repository dengan strategi cache-first untuk pengambilan data.
protocol MovieRepositoryProtocol {
    func fetchMovies(page: Int) async throws -> MovieResponse
    func fetchPopularMovies(page: Int) async throws -> MovieResponse
    func fetchSearchMovies(query: String, page: Int) async throws -> MovieResponse
    func fetchMovieDetail(movieId: Int) async throws -> MovieDetail
    func fetchMovieReviews(movieId: Int) async throws -> [Review]
    func fetchMovieVideos(movieId: Int) async throws -> [Video]
    func fetchMovieDetailWithExtras(movieId: Int) async throws -> (detail: MovieDetail, reviews: [Review], videos: [Video])
}
