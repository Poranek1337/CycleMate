//
//  StatsComponent.swift
//  CycleMate
//
//  Created by Poranek on 11/01/2025.
//

import SwiftUI

struct StatsComponent: View {
    var body: some View {
        VStack(spacing: 15) {
            // Calories Card
            VStack(alignment: .leading) {
                Text("Calories")
                    .foregroundColor(.gray)
                Text("923")
                    .font(.title2)
                    .bold()
                Text("KCal")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
            
            // Target Card
            VStack(alignment: .leading) {
                Text("Target")
                    .foregroundColor(.gray)
                Text("20")
                    .font(.title2)
                    .bold()
                Text("Miles in a Week")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
        }
    }
}

#Preview {
    StatsComponent()
}
