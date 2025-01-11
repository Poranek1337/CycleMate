//
//  MonthlyChartComponent.swift
//  CycleMate
//
//  Created by Poranek on 11/01/2025.
//

import SwiftUI

struct MonthlyChartComponent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Monthly Chart")
                .bold()
            Text("By Minutes")
                .foregroundColor(.gray)
            
            HStack(alignment: .bottom, spacing: 20) {
                Rectangle()
                    .frame(width: 30, height: 100)
                    .foregroundColor(.gray.opacity(0.3))
                Rectangle()
                    .frame(width: 30, height: 60)
                    .foregroundColor(.gray.opacity(0.3))
                Rectangle()
                    .frame(width: 30, height: 150)
                    .foregroundColor(.blue)
                Rectangle()
                    .frame(width: 30, height: 80)
                    .foregroundColor(.gray.opacity(0.3))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

#Preview {
    MonthlyChartComponent()
}
