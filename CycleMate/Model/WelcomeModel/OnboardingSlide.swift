//
//  OnboardingSlide.swift
//  CycleMate
//
//  Created by Poranek on 11/12/2024.
//

import Foundation
import SwiftUI

/// A model representing an onboarding slide.
struct OnboardingSlide: Identifiable {
    /// The unique identifier for the slide.
    let id = UUID()
    
    /// The title of the slide.
    let title: String
    
    /// The description of the slide.
    let description: String
    
    /// The name of the image associated with the slide.
    let imageName: String?
    
    /// The accent color for the slide.
    let accentColor: String?
    
    /// Initializes a new instance of `OnboardingSlide`.
    /// - Parameters:
    ///   - title: The title of the slide.
    ///   - description: The description of the slide.
    ///   - imageName: The name of the image associated with the slide.
    ///   - accentColor: The accent color for the slide.
    init(title: String,
         description: String = "",
         imageName: String? = nil,
         accentColor: String? = nil) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.accentColor = accentColor
    }
}

// End of file. No additional code.