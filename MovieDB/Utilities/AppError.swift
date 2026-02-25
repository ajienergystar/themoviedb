//
//  AppError.swift
//  MovieDB
//

import Foundation

/// Error aplikasi yang informatif untuk ditampilkan ke pengguna dan untuk maintenance.
enum AppError: Error, LocalizedError {
    case network(NetworkError)
    case cache(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .network(let err):
            return err.errorDescription
        case .cache(let message):
            return "Cache: \(message)"
        case .unknown(let message):
            return message
        }
    }

    /// Saran pemulihan singkat untuk UI (mis. "Cek koneksi lalu coba lagi").
    var recoverySuggestion: String? {
        switch self {
        case .network(.invalidURL), .network(.invalidResponse), .network(.decodingError):
            return "Coba lagi nanti atau refresh."
        case .network(.httpError(let code)):
            return code == 401 ? "Periksa konfigurasi API." : "Coba lagi nanti."
        case .cache:
            return "Data akan diambil ulang dari server."
        case .unknown:
            return "Coba lagi."
        }
    }

    static func from(_ error: Error) -> AppError {
        if let net = error as? NetworkError { return .network(net) }
        if let app = error as? AppError { return app }
        return .unknown(error.localizedDescription)
    }
}
