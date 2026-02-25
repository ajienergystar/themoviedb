//  Created by Aji Prakosa on 25 February 2026.

import XCTest
@testable import MovieDB

class NetworkServiceTests: XCTestCase {
    var networkService: NetworkService!
    var urlSession: URLSession!
    
    override func setUp() {
        super.setUp()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: configuration)
        
        networkService = NetworkService(urlSession: urlSession)
    }
    
    override func tearDown() {
        networkService = nil
        urlSession = nil
        MockURLProtocol.handlers.removeAll()
        super.tearDown()
    }
    
    func testFetchMoviesSuccess() async {
        // Given
        let mockData = """
        {
            "page": 1,
            "results": [
                {
                    "id": 1,
                    "title": "Test Movie",
                    "overview": "Test overview",
                    "poster_path": "/test.jpg",
                    "backdrop_path": "/backdrop.jpg",
                    "vote_average": 8.5,
                    "release_date": "2023-01-01"
                }
            ],
            "total_pages": 10,
            "total_results": 100
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.handlers["/3/discover/movie?api_key=\(Constants.apiKey)&page=1"] = { _ in
            return (HTTPURLResponse(), mockData)
        }
        
        // When
        do {
            let response = try await networkService.fetchMovies(page: 1)
            
            // Then
            XCTAssertEqual(response.page, 1)
            XCTAssertEqual(response.results.count, 1)
            XCTAssertEqual(response.results[0].title, "Test Movie")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchMoviesFailure() async {
        // Given
        MockURLProtocol.handlers["/3/discover/movie?api_key=\(Constants.apiKey)&page=1"] = { _ in
            return (HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)!, Data())
        }
        
        // When
        do {
            _ = try await networkService.fetchMovies(page: 1)
            XCTFail("Expected to throw error but succeeded")
        } catch {
            // Then
            XCTAssertTrue(error is NetworkError)
        }
    }
}

// MARK: - Mock URLProtocol

class MockURLProtocol: URLProtocol {
    static var handlers: [String: (URLRequest) -> (HTTPURLResponse, Data)] = [:]
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: NetworkError.invalidURL)
            return
        }
        
        let path = url.path + "?" + url.query!
        
        guard let handler = MockURLProtocol.handlers[path] else {
            client?.urlProtocol(self, didFailWithError: NetworkError.invalidURL)
            return
        }
        
        let (response, data) = handler(request)
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
