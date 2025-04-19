//
//  LocationSearchView.swift
//  CycleMate
//

import SwiftUI

struct LocationSearchView: View {
    @ObservedObject var searchViewModel: LocationSearchViewModel

    var onEditingChanged: ((Bool) -> Void)?

    @State private var isLoading = false
    @State private var error: GeocodingError?

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField(
                    "Search location",
                    text: $searchViewModel.searchTextField,
                    onEditingChanged: { active in
                        onEditingChanged?(active)
                    }
                )
                .onSubmit {
                    Task {
                        isLoading = true
                        defer { isLoading = false }
                        await searchViewModel.submitSearch(text: searchViewModel.searchTextField)
                    }
                }
            }
            .padding(8)
            .background(.thinMaterial)
            .cornerRadius(10)
            .padding(.horizontal)

            if isLoading {
                ProgressView()
            } else if let error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
        }
    }
}
