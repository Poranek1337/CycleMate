//
//  PageIndicator.swift
//  CycleMate
//  dev.Poranek
//

import SwiftUI

/// A view that displays a page indicator for onboarding or other paginated content.
struct PageIndicator: View {
    /// The current page index.
    let currentPage: Int
    
    /// The total number of pages.
    let totalPages: Int
    
    /// The color for the current page indicator.
    let darkGray: Color
    
    // MARK: - Body
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

// Preview
#Preview {
    PageIndicator(currentPage: 1, totalPages: 5, darkGray: .gray)
}