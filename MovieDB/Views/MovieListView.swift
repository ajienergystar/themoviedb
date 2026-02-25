//  Created by Aji Prakosa on 25 February 2026.

// File: Views/MovieListView.swift

import SwiftUI
import Kingfisher

struct MovieListView: View {
    @StateObject private var viewModel = MovieListViewModel()
    @State private var searchText = ""
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    contentView
                }
            } else {
                NavigationView {
                    contentView
                }
            }
        }
        .onAppear {
            if viewModel.movies.isEmpty {
                viewModel.fetchMovies()
            }
        }
    }
    
    private var contentViewBase: some View {
        Group {
            if viewModel.movies.isEmpty && !viewModel.isLoading {
                emptyStateView
            } else {
                movieGridView
            }
        }
        .navigationTitle("Film Terbaru")
        .overlay(
            Group {
                if viewModel.isLoading && viewModel.movies.isEmpty {
                    ProgressView()
                }
            }
        )
        .alert(isPresented: .constant(viewModel.error != nil)) {
            let err = viewModel.error
            let text = [err?.errorDescription, err?.recoverySuggestion].compactMap { $0 }.joined(separator: " ")
            return Alert(
                title: Text("Error"),
                message: Text(text.isEmpty ? "Terjadi kesalahan." : text),
                primaryButton: .default(Text("OK")) {
                    viewModel.error = nil
                },
                secondaryButton: .default(Text("Coba Lagi")) {
                    viewModel.error = nil
                    viewModel.fetchMovies()
                }
            )
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if #available(iOS 15.0, *) {
            contentViewBase
                .searchable(text: $searchText, prompt: "Find a movie...")
                .refreshable {
                    viewModel.fetchMovies(isRefreshing: true)
                }
        } else {
            contentViewBase
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "film")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No movie found")
                .font(.headline)
                .foregroundColor(.gray)
            
            if #available(iOS 15.0, *) {
                Button("Reload") {
                    viewModel.fetchMovies()
                }
                .buttonStyle(.bordered)
            } else {
                Button("Reload") {
                    viewModel.fetchMovies()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var movieGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.movies) { movie in
                    NavigationLink {
                        MovieDetailView(movieId: movie.id)
                    } label: {
                        MoviePosterCard(movie: movie)
                            .onAppear {
                                viewModel.loadMoreMoviesIfNeeded(currentItem: movie)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            
            if viewModel.isLoading && !viewModel.movies.isEmpty {
                ProgressView()
                    .padding()
            }
        }
    }
}

struct MoviePosterCard: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CachedAsyncImage(url: movie.posterURL, aspectRatio: 2/3) {
                Image("image_default_icon")
                    .resizable()
                    .scaledToFit()
            }
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.subheadline)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text(movie.ratingText)
                        .font(.caption)
                }
                
                Text(movie.formattedReleaseDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}


struct MovieListView_Previews: PreviewProvider {
    static var previews: some View {
        MovieListView()
    }
}
