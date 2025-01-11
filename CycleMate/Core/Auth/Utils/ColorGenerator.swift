//
//  ColorGenerator.swift
//  CycleMate
//

import SwiftUI

/// Utility class for generating and managing user profile colors
struct ColorGenerator {
    /// Generates a random color suitable for profile backgrounds
    static func generateProfileColor() -> Color {
        Color(
            red: .random(in: 0.4...0.8),
            green: .random(in: 0.4...0.8),
            blue: .random(in: 0.4...0.8)
        )
    }
    
    /// Converts Color to ColorComponents for storage
    static func colorToComponents(_ color: Color) -> User.ColorComponents {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        return User.ColorComponents(red: red, green: green, blue: blue)
    }
    
    /// Generates initials from first and last name
    static func generateInitials(firstName: String, lastName: String) -> String {
        let firstInitial = firstName.prefix(1).uppercased()
        let lastInitial = lastName.prefix(1).uppercased()
        return "\(firstInitial)\(lastInitial)"
    }
}

