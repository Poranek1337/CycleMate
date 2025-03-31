//
//  ActivitySummaryView.swift
//  CycleMate
//
//  Created by Poranek on 30/03/2025.
//

import SwiftUI

struct ActivitySummaryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Activity")
                .font(.headline)
            
            VStack(spacing: 15) {
                ForEach(0..<3) { _ in
                    HStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                        
                        Text("Morning Ride")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("12.5 km")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(20)
    }
}

#Preview {
    ActivitySummaryView()
}
