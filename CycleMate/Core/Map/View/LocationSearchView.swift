//
//  LocationSearchView.swift
//  CycleMate
//

import SwiftUI

struct LocationSearchView: View {
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search for a location", text: .constant(""))
                    .padding(12)
            }
            .padding(.horizontal)
            .background(.ultraThinMaterial)
            .cornerRadius(.infinity)
        }
        .padding(.horizontal)
    }
}

#Preview {
    MapView()
}
