//
//  ImageLoader.swift
//  MovieDB
//

import SwiftUI
import Kingfisher

/// Helper untuk memuat gambar dengan cache (Kingfisher) dan placeholder.
/// Mengurangi ukuran decode untuk performa scroll yang lebih smooth.
struct CachedAsyncImage<Placeholder: View>: View {
    let url: URL?
    let placeholder: () -> Placeholder
    let aspectRatio: CGFloat
    let maxSize: CGSize

    init(
        url: URL?,
        aspectRatio: CGFloat = 2/3,
        maxSize: CGSize = CGSize(width: 500, height: 750),
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.aspectRatio = aspectRatio
        self.maxSize = maxSize
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let url = url {
                KFImage(url)
                    .placeholder(placeholder)
                    .setProcessor(DownsamplingImageProcessor(size: maxSize))
                    .cacheMemoryOnly(false)
                    .fade(duration: 0.2)
                    .onFailure { _ in }
                    .resizable()
                    .aspectRatio(aspectRatio, contentMode: .fit)
            } else {
                placeholder()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(aspectRatio, contentMode: .fit)
            }
        }
    }
}
