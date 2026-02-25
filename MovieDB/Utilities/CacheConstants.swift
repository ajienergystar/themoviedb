//
//  CacheConstants.swift
//  MovieDB
//

import Foundation

enum CacheConstants {
    /// Durasi cache daftar film (detik). Setelah ini, data dianggap kadaluarsa.
    static let movieListExpiryInterval: TimeInterval = 300 // 5 menit
    
    /// Durasi cache detail film (detik).
    static let movieDetailExpiryInterval: TimeInterval = 3600 // 1 jam
}
