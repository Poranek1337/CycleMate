//
//  SavedRoutesView.swift
//  CycleMate
//
//  Created by Poranek on 30/03/2025.
//

import SwiftUI

struct SavedRoutesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Saved Routes")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<3) { _ in
                        RouteCardView()
                    }
                }
            }
        }
    }
}

#Preview {
    SavedRoutesView()
}
