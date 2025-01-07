//
//  FirstLaunchView.swift
//  CycleMate
//  dev.Poranek
//

import SwiftUI

/// A view that handles the first launch experience with onboarding slides and authentication.
struct FirstLaunchView: View {
    // MARK: - Properties
    
    /// The view model for managing state and logic.
    @StateObject private var viewModel = FirstLaunchViewModel()
    
    /// A flag indicating if the authentication card should be shown.
    @State private var showAuthCard = false
    
    /// A flag indicating if the main tab view should be shown.
    @State private var shouldShowMainTab = false
    
    /// The environment object for authentication view model.
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    // MARK: - Body
    var body: some View {
        Group {
            if shouldShowMainTab {
                MainTabView()
            } else {
                // Wrap the onboarding content in a ZStack with a solid background
                ZStack {
                    // Add solid background color
                    Color.white.edgesIgnoringSafeArea(.all)
                    
                    onboardingContent
                }
            }
        }
        .onChange(of: authViewModel.currentUser) { user in
            if user != nil {
                print(" User authenticated, switching to MainTabView")
            }
        }
    }
    
    /// The content for the onboarding slides.
    private var onboardingContent: some View {
        ZStack {
            // Background Image
            if let imageName = viewModel.slides[viewModel.currentPage].imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
            }
            
            // Semi-transparent overlay
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack(spacing: 30) {
                Spacer()
                
                // Text content at the bottom
                VStack(spacing: 20) {
                    // Title with animated characters
                    HStack(spacing: 0) {
                        ForEach(Array(viewModel.slides[viewModel.currentPage].title.enumerated()), id: \.offset) { index, character in
                            Text(String(character))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .transition(AnyTransition.opacity
                                    .combined(with: .move(edge: .top))
                                    .animation(.easeInOut(duration: 0.3)
                                        .delay(Double(index) * 0.02)))
                        }
                    }
                    .id("title_\(viewModel.currentPage)")
                    
                    // Description with animated characters
                    HStack(spacing: 0) {
                        ForEach(Array(viewModel.slides[viewModel.currentPage].description.enumerated()), id: \.offset) { index, character in
                            Text(String(character))
                                .font(.body)
                                .foregroundColor(.white)
                                .transition(AnyTransition.opacity
                                    .combined(with: .move(edge: .bottom))
                                    .animation(.easeInOut(duration: 0.3)
                                        .delay(Double(index) * 0.015)))
                        }
                    }
                    .id("description_\(viewModel.currentPage)")
                    .padding(.horizontal)
                }
                
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.totalPages, id: \.self) { index in
                        Capsule()
                            .fill(Color.white.opacity(index == viewModel.currentPage ? 1 : 0.3))
                            .frame(width: index == viewModel.currentPage ? 16 : 4, height: 4)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.currentPage)
                    }
                }
                .padding(.bottom, 10)
                
                // Navigation button
                Button {
                    if viewModel.currentPage == viewModel.totalPages - 1 {
                        showAuthCard = true
                    } else {
                        viewModel.nextPage()
                    }
                } label: {
                    Text(viewModel.currentPage == viewModel.totalPages - 1 ? "Get Started" : "Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
            
            // Auth card overlay with navigation callback
            if showAuthCard {
                AuthenticationView(isPresented: $showAuthCard, onSuccessfulAuth: {
                    withAnimation {
                        shouldShowMainTab = true
                    }
                })
                .environmentObject(authViewModel)
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            viewModel.animateContent = true
        }
    }
}

// Preview
#Preview {
    FirstLaunchView()
        .environmentObject(AuthViewModel())
}
