//
//  PopularMoviesView.swift
//  MovieDB
//

import SwiftUI
import Kingfisher

struct PopularMoviesView: View {
    @StateObject private var viewModel = PopularMoviesViewModel()
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        Group {
            if viewModel.movies.isEmpty && !viewModel.isLoading {
                emptyStateView
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.movies) { movie in
                            NavigationLink {
                                MovieDetailView(movieId: movie.id)
                            } label: {
                                MoviePosterCard(movie: movie)
                                    .onAppear {
                                        viewModel.loadMoreIfNeeded(currentItem: movie)
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
        .navigationTitle("Film Populer")
        .refreshableCompat { viewModel.fetchMovies(isRefreshing: true) }
        .loadingOverlay(isVisible: viewModel.isLoading && viewModel.movies.isEmpty)
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.error != nil },
            set: { newValue in
                if !newValue {
                    viewModel.error = nil
                }
            }
        )) {
            let err = viewModel.error
            let text = [err?.errorDescription, err?.recoverySuggestion].compactMap { $0 }.joined(separator: " ")
            return Alert(
                title: Text("Error"),
                message: Text(text.isEmpty ? "Terjadi kesalahan." : text),
                primaryButton: .default(Text("Coba Lagi")) {
                    viewModel.error = nil
                    viewModel.fetchMovies()
                },
                secondaryButton: .cancel(Text("OK")) {
                    viewModel.error = nil
                }
            )
        }
        .onAppear {
            if viewModel.movies.isEmpty {
                viewModel.fetchMovies()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "film")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("Belum ada film populer")
                .font(.headline)
                .foregroundColor(.gray)
            if #available(iOS 15.0, *) {
                Button("Muat Ulang") {
                    viewModel.fetchMovies()
                }
                .buttonStyle(.bordered)
            } else {
                Button("Muat Ulang") {
                    viewModel.fetchMovies()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension View {
    @ViewBuilder
    func refreshableCompat(action: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, *) {
            self.refreshable {
                action()
            }
        } else {
            self
        }
    }

    @ViewBuilder
    func loadingOverlay(isVisible: Bool) -> some View {
        if isVisible {
            ZStack {
                self
                ProgressView()
            }
        } else {
            self
        }
    }
}

#Preview {
    NavigationView {
        PopularMoviesView()
    }
}
