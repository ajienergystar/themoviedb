//
//  MovieDetailCache.swift
//  MovieDB
//

import Foundation

/// Model untuk menyimpan detail film + reviews + videos di cache (satu blob).
struct MovieDetailCache: Codable {
    let detail: MovieDetail
    let reviews: [Review]
    let videos: [Video]
}
