//
//  StatsGridView.swift
//  CycleMate
//
//  Created by Poranek on 30/03/2025.
//

import SwiftUI

struct StatsGridView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showStats = false
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            StatisticCardView(
                title: "Total Distance",
                value: 156.5,
                unit: "km",
                icon: "figure.walk",
                color: .blue,
                showStats: showStats
            )
            
            StatisticCardView(
                title: "Total Rides",
                value: 24,
                unit: "rides",
                icon: "bicycle",
                color: .green,
                showStats: showStats
            )
            
            StatisticCardView(
                title: "Calories Burned",
                value: 4328,
                unit: "kcal",
                icon: "flame.fill",
                color: .orange,
                showStats: showStats
            )
            
            StatisticCardView(
                title: "Achievements",
                value: 12,
                unit: "",
                icon: "trophy.fill",
                color: .yellow,
                showStats: showStats
            )
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showStats = true
            }
        }
    }
}

#Preview {
    StatsGridView()
}
