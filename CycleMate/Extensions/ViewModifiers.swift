//
//  ViewModifiers.swift
//  CycleMate
//
//  Created by Poranek on 15/12/2024.
//

import SwiftUI

// Extension for custom corner radius
extension View {
    /// Applies a corner radius to specific corners of the view.
    /// - Parameters:
    ///   - radius: The radius of the corners.
    ///   - corners: The corners to apply the radius to.
    /// - Returns: A view with the specified corner radius applied.
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    /// Conditionally applies a transformation to the view.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transformation to apply if the condition is true.
    /// - Returns: The original view or the transformed view based on the condition.
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// Rounded corner shape for partial corner rounding
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// End of file. No additional code.