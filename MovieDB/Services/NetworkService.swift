//  Created by Aji Prakosa on 25 February 2026.

import Foundation


protocol NetworkServiceProtocol {
    func fetchMovies(page: Int) async throws -> MovieResponse
    func fetchPopularMovies(page: Int) async throws -> MovieResponse
    func fetchSearchMovies(query: String, page: Int) async throws -> MovieResponse
    func fetchMovieDetails(id: Int) async throws -> MovieDetail
    func fetchMovieReviews(id: Int) async throws -> ReviewResponse
    func fetchMovieVideos(id: Int) async throws -> VideoResponse
}

class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    private func fetchData<T: Decodable>(from endpoint: String, parameters: [String: String] = [:]) async throws -> T {
        let url = try buildURL(for: endpoint, parameters: parameters)
        let (data, response) = try await urlSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }
    
    func fetchMovies(page: Int) async throws -> MovieResponse {
        let parameters = ["page": String(page)]
        return try await fetchData(from: Constants.Endpoints.discoverMovies, parameters: parameters)
    }

    func fetchPopularMovies(page: Int) async throws -> MovieResponse {
        let parameters = ["page": String(page)]
        return try await fetchData(from: Constants.Endpoints.popularMovies, parameters: parameters)
    }

    func fetchSearchMovies(query: String, page: Int) async throws -> MovieResponse {
        var parameters = ["page": String(page)]
        if !query.trimmingCharacters(in: .whitespaces).isEmpty {
            parameters["query"] = query
        }
        return try await fetchData(from: Constants.Endpoints.searchMovies, parameters: parameters)
    }

    func fetchMovieDetails(id: Int) async throws -> MovieDetail {
        return try await fetchData(from: "\(Constants.Endpoints.movieDetails)/\(id)")
    }
    
    func fetchMovieReviews(id: Int) async throws -> ReviewResponse {
        let endpoint = String(format: Constants.Endpoints.movieReviews, id)
        let response: ReviewResponse = try await fetchData(from: endpoint)
        return response
    }
    
    func fetchMovieVideos(id: Int) async throws -> VideoResponse {
        return try await fetchData(from: String(format: Constants.Endpoints.movieVideos, id))
    }
    
    private func buildURL(for endpoint: String, parameters: [String: String] = [:]) throws -> URL {
        guard let baseURL = URL(string: Constants.baseURL) else {
            throw NetworkError.invalidURL
        }
        
        let url = baseURL.appendingPathComponent(endpoint)
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems = [URLQueryItem(name: "api_key", value: Constants.apiKey)]
        
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        components.queryItems = queryItems
        
        guard let finalURL = components.url else {
            throw NetworkError.invalidURL
        }
        
        return finalURL
    }
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let statusCode):
            return "Error HTTP: \(statusCode)"
        case .decodingError(let message):
            return "Error decoding: \(message)"
        }
    }
}


extension JSONDecoder {
    static var movieDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.userInfo[CodingUserInfoKey(rawValue: "decodeMissingKeysAsNil")!] = true
        return decoder
    }
}
