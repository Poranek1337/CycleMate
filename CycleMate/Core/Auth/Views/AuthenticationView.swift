//
//  AuthenticationView.swift
//  CycleMate
//  dev.Poranek
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

/// A view that handles user authentication.
struct AuthenticationView: View {
    // MARK: - Properties
    
    /// The view model for authentication.
    @StateObject private var viewModel = AuthViewModel()
    
    /// A binding to determine if the view is presented.
    @Binding var isPresented: Bool
    
    /// The action to perform on successful authentication.
    var onSuccessfulAuth: () -> Void
    
    /// The offset for the view.
    @State private var offset: CGFloat = UIScreen.main.bounds.height
    
    /// A flag indicating if the view is being dragged.
    @State private var isDragging = false
    
    /// A flag indicating if the main tab view should be shown.
    @State private var showMainTabView = false
    
    /// A new state for email signup
    @State private var showEmailSignUp = false
    
    /// A state for email login
    @State private var showEmailLogin = false
    
    /// The background opacity based on the offset.
    private var backgroundOpacity: Double {
        let progress = 1 - (offset / UIScreen.main.bounds.height)
        return Double(max(0, min(0.3, progress * 0.3)))
    }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .opacity(backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissCard()
                }
            
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 50, height: 5)
                    .cornerRadius(2.5)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 15)
                    .padding(.bottom, 15)
                
                VStack(spacing: 25) {
                    AuthButton(
                        title: "Sign Up",
                        style: .primary
                    ) {
                        showEmailSignUp = true
                    }
                    
                    AuthButton(
                        title: "Login to CycleMate",
                        style: .outlined
                    ) {
                        showEmailLogin = true
                    }
                    
                    HStack {
                        Line()
                        Text("or")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 1)
                        Line()
                    }
                    .padding(.vertical, 10)
                    
                    VStack(spacing: 15) {
                        AuthButton(
                            title: "Continue with Apple",
                            systemImage: "apple.logo",
                            style: .outlined
                        ) {
                            // Apple login
                        }
                        
                        AuthButton(
                            title: "Continue with Facebook",
                            systemImage: "f.square.fill",
                            style: .outlined
                        ) {
                            // Facebook login
                        }
                        
                        AuthButton(
                            title: "Continue with Google",
                            systemImage: "g.circle.fill",
                            style: .outlined
                        ) {
                           // Google login
                        }
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 5)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height / 1.7)
            .background(Color(.systemBackground))
            .cornerRadius(25, corners: [.topLeft, .topRight])
            .offset(y: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newOffset = value.translation.height
                        if newOffset > 0 {
                            offset = newOffset
                            isDragging = true
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > 100 {
                            dismissCard()
                        } else {
                            withAnimation(.spring()) {
                                offset = 0
                                isDragging = false
                            }
                        }
                    }
            )
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                offset = 0
            }
        }
        .onChange(of: showMainTabView) { oldValue, newValue in
            if newValue {
                DispatchQueue.main.async {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController = UIHostingController(rootView: MainTabView())
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showUserDataForm) {
            UserDataFormView(viewModel: viewModel)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $showEmailSignUp) {
            EmailSignUpView()
        }
        .overlay {
            if showEmailLogin {
                EmailLoginView(isPresented: $showEmailLogin)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Dismisses the card view with animation.
    private func dismissCard() {
        withAnimation(.spring()) {
            offset = UIScreen.main.bounds.height
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}

// MARK: - Helper Views

/// A view representing a horizontal line.
struct Line: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: 1)
    }
}

#Preview {
    AuthenticationView(isPresented: .constant(true), onSuccessfulAuth: {})
}
