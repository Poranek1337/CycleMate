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
    @State private var showContent = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Group {
                if authViewModel.currentUser != nil {
                    MainTabView()
                        .background(Color.clear)
                        .environmentObject(authViewModel)
                } else {
                    FirstLaunchView()
                        .background(Color.clear)
                }
            }
            
            Color("second")
                .edgesIgnoringSafeArea(.all)
                .opacity(showContent ? 0 : 1)
            
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
                    Task {
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        
                        withAnimation(.easeInOut(duration: 0.7)) {
                            self.offset = geometry.size.height + 200
                            self.padding = 100
                            self.showContent = true
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
