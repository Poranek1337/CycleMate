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
    
    /// Converts Color to hex string
    static func colorToHexString(_ color: Color) -> String {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb: Int = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255) << 0
        
        return String(format: "#%06x", rgb)
    }
    
    /// Converts hex string to Color
    static func hexStringToColor(_ hex: String) -> Color? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
    }
    
    /// Generates initials from first and last name
    static func generateInitials(firstName: String, lastName: String) -> String {
        let firstInitial = firstName.prefix(1).uppercased()
        let lastInitial = lastName.prefix(1).uppercased()
        return "\(firstInitial)\(lastInitial)"
    }
}
