//
//  PageIndicator.swift
//  CycleMate
//
//  Created by Poranek on 11/12/2024.
//

import SwiftUI

struct PageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    let darkGray: Color
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Group {
                    if index == currentPage {
                        Capsule()
                            .fill(darkGray)
                            .frame(width: 16, height: 4)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 4, height: 4)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
            }
        }
    }
}


