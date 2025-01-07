//
//  SplashScreenView.swift
//  CycleMate
//

import SwiftUI

/// A view that displays the splash screen and handles navigation to the appropriate view based on the authentication state.
struct SplashScreenView: View {
    // MARK: - Properties
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var offset: CGFloat = 0
    @State private var padding: CGFloat = 0
    @State private var showNextView = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Pre-load next view immediately but keep it hidden
            Group {
                if let user = authViewModel.currentUser {
                    // User has an active session, show MainTabView
                    MainTabView()
                        .opacity(showNextView ? 1 : 0)
                } else {
                    // No active session, show FirstLaunchView
                    FirstLaunchView()
                        .opacity(showNextView ? 1 : 0)
                }
            }
            
            // Splash screen content
            GeometryReader { geometry in
                ZStack {
                    ArcShape()
                        .fill(Color("second"))
                    
                    Image("bike")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                }
                .edgesIgnoringSafeArea(.all)
                .offset(y: offset)
                .padding(.bottom, padding)
                .onAppear {
                    // Check for existing session
                    Task {
                        // Give time for AuthViewModel to initialize
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                        
                        // Animate splash screen after delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeInOut(duration: 0.7)) {
                                // Increased offset to move splash screen further down
                                self.offset = geometry.size.height + 200
                                self.padding = 100
                            }
                            
                            // Show next view after animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    showNextView = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Shape

/// A custom shape used in the splash screen.
struct ArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: 0),
                         control: CGPoint(x: rect.midX, y: -50))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        return path
    }
}

// MARK: - Preview
struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
            .environmentObject(AuthViewModel())
    }
}

// End of file. No additional code.
