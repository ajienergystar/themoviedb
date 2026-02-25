//
//  ContentView.swift
//  MovieDB
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                PopularMoviesView()
            }
            .tabItem {
                Label("Film Populer", systemImage: "film.stack")
            }

            NavigationView {
                SearchMoviesView()
            }
            .tabItem {
                Label("Pencarian", systemImage: "magnifyingglass")
            }

            NavigationView {
                MovieListView()
            }
            .tabItem {
                Label("Terbaru", systemImage: "clock")
            }

            NavigationView {
                FavoritesView()
            }
            .tabItem {
                Label("Favorit", systemImage: "heart")
            }
        }
    }
}

#Preview {
    ContentView()
}
