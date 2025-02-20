//
//  FirstLaunchViewModel.swift
//  CycleMate
//
//  Created by Poranek on 11/12/2024.
//

import SwiftUI

/// Manages the first launch experience and onboarding flow.
class FirstLaunchViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var animateContent = false
    @Published var isTransitioning = false
    @Published var showAuthView = false
    
    // Your slides remain the same
    let slides = [
        OnboardingSlide(
            title: "Welcome to CycleMate!",
            description: "Your cycling companion app.",
            imageName: "zdj1",
            accentColor: "second"
        ),
        OnboardingSlide(
            title: "Track your cycling journey",
            description: "Monitor your progress",
            imageName: "zdj2",
            accentColor: "second"
        ),
        OnboardingSlide(
            title: "Let's get started!",
            description: "Begin your adventure",
            imageName: "zdj3",
            accentColor: "second"
        )
    ]
    
    var totalPages: Int {
        slides.count
    }
    
    /// Handles navigation and animations for next page or completion
    func nextPage() {
        if currentPage == totalPages - 1 {
            // Show auth view when on last page
            withAnimation {
                showAuthView = true
            }
            return
        }
        
        // Regular page transition
        withAnimation(.easeOut(duration: 0.3)) {
            animateContent = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.currentPage += 1
                self.currentPage = min(self.currentPage, self.totalPages - 1)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 0.5)) {
                    self.animateContent = true
                }
            }
        }
    }
}
