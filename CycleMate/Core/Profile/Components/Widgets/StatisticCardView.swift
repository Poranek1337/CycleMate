//
//  StatisticCardView.swift
//  CycleMate
//
//  Created by Poranek on 30/03/2025.
//

import SwiftUI

struct StatisticCardView: View {
    let title: String
    let value: Double
    let unit: String
    let icon: String
    let color: Color
    let showStats: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .scaleEffect(showStats ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showStats)
            
            Text("0")
                .font(.title2)
                .bold()
                .modifier(CounterAnimation(
                    end: showStats ? value : 0,
                    duration: 1.5,
                    decimalPlaces: unit == "km" ? 1 : 0,
                    animation: .linear(duration: 1.5)
                ))
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.gray)
                .opacity(showStats ? 1 : 0)
                .animation(.easeIn(duration: 0.3).delay(0.3), value: showStats)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .opacity(showStats ? 1 : 0)
                .animation(.easeIn(duration: 0.3).delay(0.4), value: showStats)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(20)
        .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
        .scaleEffect(showStats ? 1 : 0.8)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showStats)
    }
}

#Preview {
    StatisticCardView(title: "Distance", value: 10.5, unit: "km", icon: "map.fill", color: .blue, showStats: true)
}
