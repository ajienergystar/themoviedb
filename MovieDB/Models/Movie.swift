//  Created by Aji Prakosa on 25 February 2026.

import Foundation

struct MovieResponse: Codable {
    let page: Int?
    let results: [Movie]
    let totalPages: Int?
    let totalResults: Int?
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
    
    var currentPage: Int { page ?? 1 }
    var totalPagesCount: Int { totalPages ?? 1 }
    var totalResultsCount: Int { totalResults ?? 0 }
}

struct Movie: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?  // Jadikan optional
    let releaseDate: String?
    let adult: Bool?
    let genreIds: [Int]?
    let originalTitle: String?
    let originalLanguage: String?
    let popularity: Double?
    let video: Bool?
    let voteCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, adult
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case genreIds = "genre_ids"
        case originalTitle = "original_title"
        case originalLanguage = "original_language"
        case popularity, video
        case voteCount = "vote_count"
    }
    
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: Constants.imageBaseURL + posterPath)
    }
    
    var ratingText: String {
        guard let voteAverage = voteAverage else { return "N/A" }
        return String(format: "%.1f", voteAverage)
    }
    
    var formattedReleaseDate: String {
        guard let releaseDate = releaseDate else { return "TBA" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: releaseDate) else { return releaseDate }
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}


struct MovieDetail: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?
    let releaseDate: String?
    let runtime: Int?
    let genres: [Genre]
    let tagline: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, genres, tagline
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }
    
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: Constants.imageBaseURL + posterPath)
    }
    
    var backdropURL: URL? {
        guard let backdropPath = backdropPath else { return nil }
        return URL(string: Constants.imageBaseURL + backdropPath)
    }
    
    var formattedRuntime: String {
        guard let runtime = runtime else { return "N/A" }
        let hours = runtime / 60
        let minutes = runtime % 60
        return "\(hours)h \(minutes)m"
    }
    
    var genreText: String {
        genres.map { $0.name }.joined(separator: ", ")
    }
    
    var formattedReleaseDate: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: releaseDate ?? "") else { return releaseDate }
        
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}

struct Genre: Codable {
    let id: Int
    let name: String
}

struct ReviewResponse: Codable {
    let results: [Review]
}

struct Review: Codable, Identifiable {
    let id: String
    let author: String
    let content: String
    let createdAt: String?  // Jadikan optional
    
    enum CodingKeys: String, CodingKey {
        case id, author, content
        case createdAt = "created_at"
    }
    
    var formattedDate: String {
        guard let createdAt = createdAt, !createdAt.isEmpty else {
            return "Without Date"
        }
        
        let dateFormatter = DateFormatter()
        let possibleFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        
        for format in possibleFormats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: createdAt) {
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                return dateFormatter.string(from: date)
            }
        }
        
        return createdAt
    }
}

struct VideoResponse: Codable {
    let results: [Video]
}

struct Video: Codable, Identifiable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
    
    var youtubeURL: URL? {
        guard site == "YouTube" else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(key)")
    }
}

extension Movie {
    init(id: Int, title: String, overview: String, posterPath: String? = nil, backdropPath: String? = nil,
         voteAverage: Double? = nil, releaseDate: String? = nil) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.voteAverage = voteAverage
        self.releaseDate = releaseDate
        self.adult = nil
        self.genreIds = nil
        self.originalTitle = nil
        self.originalLanguage = nil
        self.popularity = nil
        self.video = nil
        self.voteCount = nil
    }
}
