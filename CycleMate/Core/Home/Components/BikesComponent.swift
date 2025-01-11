//
//  BikesComponent.swift
//  CycleMate
//
//  Created by Poranek on 11/01/2025.
//

import SwiftUI

struct BikesComponent: View {
    var body: some View {
        VStack {
            Text("MY BIKES")
                .bold()
            Rectangle()
                .frame(width: 100, height: 100)
                .foregroundColor(.yellow.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.yellow.opacity(0.2))
        .cornerRadius(20)
    }
}

#Preview {
    BikesComponent()
}
