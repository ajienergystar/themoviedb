//  Created by Aji Prakosa on 25 February 2026.


import SwiftUI
import Kingfisher
import WebKit

struct MovieDetailView: View {
    @StateObject private var viewModel: MovieDetailViewModel
    @ObservedObject private var favoritesStore = FavoritesStore.shared
    @State private var selectedTab: DetailTab = .about
    @State private var isShowingErrorAlert = false

    init(movieId: Int) {
        _viewModel = StateObject(wrappedValue: MovieDetailViewModel(movieId: movieId))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let movieDetail = viewModel.movieDetail {
                    headerView(movieDetail: movieDetail)
                    
                    Picker("Tab", selection: $selectedTab) {
                        ForEach(DetailTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    switch selectedTab {
                    case .about:
                        aboutTab(movieDetail: movieDetail)
                    case .reviews:
                        reviewsTab
                    case .trailer:
                        trailerTab
                    }
                } else if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 300)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    if let detail = viewModel.movieDetail {
                        favoritesStore.toggleFavorite(detail: detail)
                    }
                } label: {
                    let isFavorite = viewModel.movieDetail.map { favoritesStore.isFavorite(movieId: $0.id) } ?? false
                    
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .primary)
                }
                .disabled(viewModel.movieDetail == nil)
            }
        }
        .onReceive(viewModel.$error) { newError in
            isShowingErrorAlert = newError != nil
        }
        .alert(isPresented: $isShowingErrorAlert) {
            let err = viewModel.error
            let text = [err?.errorDescription, err?.recoverySuggestion].compactMap { $0 }.joined(separator: " ")
            
            return Alert(
                title: Text("Error"),
                message: Text(text.isEmpty ? "Terjadi kesalahan." : text),
                primaryButton: .default(Text("Coba Lagi")) {
                    viewModel.error = nil
                    viewModel.fetchMovieDetails(movieId: viewModel.movieId)
                },
                secondaryButton: .cancel(Text("OK")) {
                    viewModel.error = nil
                }
            )
        }
    }
    
    private func headerView(movieDetail: MovieDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .bottom) {
                KFImage(movieDetail.backdropURL)
                    .resizable()
                    .placeholder {
                        Color.gray.opacity(0.2)
                    }
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 80)
                
                HStack(alignment: .bottom, spacing: 16) {
                    KFImage(movieDetail.posterURL)
                        .resizable()
                        .placeholder {
                            Image(systemName: "film")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.gray.opacity(0.2))
                        }
                        .aspectRatio(2/3, contentMode: .fit)
                        .frame(width: 100)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                        .offset(y: 20)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(movieDetail.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(2)
                        
                        HStack(spacing: 16) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                
                                Text(String(format: "%.1f", movieDetail.voteAverage ?? 0))
                            }
                            
                            Text(movieDetail.formattedRuntime)
                        }
                        .font(.subheadline)
                        
                        Text(movieDetail.genreText)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .offset(y: 10)
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            if let tagline = movieDetail.tagline, !tagline.isEmpty {
                Text(tagline)
                    .font(.subheadline)
                    .italic()
                    .padding(.horizontal)
            }
        }
    }
    
    private func aboutTab(movieDetail: MovieDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sinopsis")
                .font(.headline)
            
            Text(movieDetail.overview)
                .font(.body)
            
            if !movieDetail.genres.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Genre")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(movieDetail.genres, id: \.id) { genre in
                                Text(genre.name)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Informasi")
                    .font(.headline)
                
                infoRow(label: "Release Date", value: movieDetail.formattedReleaseDate ?? "")
                infoRow(label: "Duration", value: movieDetail.formattedRuntime)
                infoRow(label: "Rating", value: String(format: "%.1f", movieDetail.voteAverage ?? 0))
            }
        }
        .padding()
    }
    
    private var reviewsTab: some View {
        Group {
            if viewModel.reviews.isEmpty {
                Text("No reviews yet")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.reviews) { review in
                        ReviewCard(review: review)
                    }
                }
                .padding()
            }
        }
    }
    
    private var trailerTab: some View {
        Group {
            if let trailer = viewModel.youtubeTrailer {
                YouTubePlayerView(videoID: trailer.key)
                    .frame(height: 220)
                    .cornerRadius(8)
                    .padding()
            } else {
                Text("Trailer not available")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }
    
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
            Spacer()
        }
        .font(.subheadline)
    }
}

struct ReviewCard: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.author)
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if review.createdAt != nil {
                    Text(review.formattedDate)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Text(review.content)
                .font(.body)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: "https://www.youtube.com/embed/\(videoID)") else { return }
        uiView.scrollView.isScrollEnabled = false
        uiView.load(URLRequest(url: url))
    }
}

enum DetailTab: String, CaseIterable {
    case about = "About"
    case reviews = "Reviews"
    case trailer = "Trailer"
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailView(movieId: 550)
    }
}
