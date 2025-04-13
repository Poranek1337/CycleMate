// MOVE: UIColor extensions to a new file
import UIKit
import SwiftUI

extension UIColor {
    func encode() -> [CGFloat] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return [red, green, blue]
    }
    
    static func decode(_ components: [CGFloat]) -> UIColor {
        return UIColor(red: components[0],
                      green: components[1],
                      blue: components[2],
                      alpha: 1.0)
    }
}