//
//  RouteCardView.swift
//  CycleMate
//
//  Created by Poranek on 30/03/2025.
//

import SwiftUI

struct RouteCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 150, height: 100)
                .overlay(
                    Image(systemName: "map.fill")
                        .foregroundColor(.white)
                )
            
            Text("City Loop")
                .font(.subheadline)
                .bold()
            
            Text("12.5 km • 45 min")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    RouteCardView()
}
