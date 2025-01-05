//
//  OnboardingSlide.swift
//  CycleMate
//
//  Created by Poranek on 11/12/2024.
//

import Foundation
import SwiftUI

struct OnboardingSlide: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String?
    let accentColor: String?
    
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



