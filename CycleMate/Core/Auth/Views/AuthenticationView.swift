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
    
    /// The background opacity based on the offset.
    private var backgroundOpacity: Double {
        let progress = 1 - (offset / UIScreen.main.bounds.height)
        return Double(max(0, min(0.3, progress * 0.3)))
    }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            // Semi-transparent background
            Color.black
                .opacity(backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissCard()
                }
            
            // Card View
            VStack(spacing: 0) {
                // Handle indicator at the very top
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 50, height: 5)
                    .cornerRadius(2.5)
                    .padding(.top, 12)
                    .padding(.bottom, 30)
                
                // Content
                VStack(spacing: 25) {
                    // Primary action buttons
                    AuthButton(
                        title: "Sign Up",
                        style: .primary
                    ) {
                        // Add sign up action
                    }
                    
                    AuthButton(
                        title: "Login to CycleMate",
                        style: .outlined
                    ) {
                        // Add login action
                    }
                    
                    // Divider with 'or'
                    HStack {
                        Line()
                        Text("or")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        Line()
                    }
                    .padding(.vertical, 15)
                    
                    // Social login buttons
                    VStack(spacing: 20) {
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
                            Task {
                                do {
                                    print("🔵 Starting Google sign in")
                                    try await viewModel.signInWithGoogle()
                                    
                                    if let user = Auth.auth().currentUser {
                                        let userRef = Firestore.firestore().collection("users").document(user.uid)
                                        let document = try await userRef.getDocument()
                                        
                                        if document.exists {
                                            print("✅ Existing user found, loading profile")
                                            withAnimation {
                                                onSuccessfulAuth()
                                                dismissCard()
                                            }
                                        }
                                    }
                                } catch {
                                    print("❌ Google Sign In failed: \(error)")
                                    viewModel.errorMessage = error.localizedDescription
                                    viewModel.showError = true
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
                .padding(.bottom, 40)
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
        .onChange(of: showMainTabView) { newValue in
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

// Preview remains the same
#Preview {
    AuthenticationView(isPresented: .constant(true), onSuccessfulAuth: {})
}