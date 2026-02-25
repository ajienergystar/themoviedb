//
//  SearchMoviesView.swift
//  MovieDB
//

import SwiftUI
import Kingfisher

struct SearchMoviesView: View {
    @StateObject private var viewModel = SearchMoviesViewModel()
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        Group {
            if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                placeholderView
            } else if viewModel.movies.isEmpty && !viewModel.isLoading {
                emptyStateView
            } else {
                movieGridView
            }
        }
        .navigationTitle("Pencarian Film")
        .searchableCompat(text: $searchText) {
            viewModel.search(query: searchText)
        }
        .onChange(of: searchText) { newValue in
            let trimmed = newValue.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                viewModel.search(query: "")
                return
            }
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(nanoseconds: 400_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    viewModel.search(query: trimmed)
                }
            }
        }
        .overlay(
            Group {
                if viewModel.isLoading && viewModel.movies.isEmpty && !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
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
                primaryButton: .default(Text("Coba Lagi")) {
                    viewModel.error = nil
                    viewModel.search(query: searchText)
                },
                secondaryButton: .cancel(Text("OK")) {
                    viewModel.error = nil
                }
            )
        }
    }

    private var placeholderView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("Ketik nama film untuk mencari")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "film.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("Tidak ada hasil untuk \"\(searchText)\"")
                .font(.headline)
                .foregroundColor(.gray)
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

extension View {
    @ViewBuilder
    func searchableCompat(text: Binding<String>, onSubmit: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, *) {
            self
                .searchable(text: text, prompt: "Cari film...")
                .onSubmit(of: .search, onSubmit)
        } else {
            self
        }
    }
}

#Preview {
    NavigationView {
        SearchMoviesView()
    }
}
