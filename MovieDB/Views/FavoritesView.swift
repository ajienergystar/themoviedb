//
//  FavoritesView.swift
//  MovieDB
//

import SwiftUI
import Kingfisher

struct FavoritesView: View {
    @StateObject private var favoritesStore = FavoritesStore.shared
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        Group {
            if favoritesStore.favorites.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(favoritesStore.favorites) { item in
                            NavigationLink {
                                MovieDetailView(movieId: item.id)
                            } label: {
                                FavoritePosterCard(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Film Favorit")
        .onAppear {
            favoritesStore.loadFavorites()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("Belum ada film favorit")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Tambahkan dari detail film dengan tombol hati")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FavoritePosterCard: View {
    let item: FavoriteMovieItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CachedAsyncImage(url: item.posterURL, aspectRatio: 2/3) {
                Image("image_default_icon")
                    .resizable()
                    .scaledToFit()
            }
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(item.ratingText)
                        .font(.caption)
                }

                Text(item.formattedReleaseDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            FavoritesView()
        }
    } else {
        NavigationView {
            FavoritesView()
        }
    }
}
