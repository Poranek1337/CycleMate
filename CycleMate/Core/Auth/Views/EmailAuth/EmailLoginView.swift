//
//  EmailLoginView.swift
//  CycleMate
//  dev.Poranek
//

import SwiftUI
import Firebase
import FirebaseAuth

/// A view that handles email login.
struct EmailLoginView: View {
    // MARK: - Properties
    
    /// The view model for authentication.
    @StateObject private var viewModel = AuthViewModel()
    
    /// A binding to determine if the view is presented.
    @Binding var isPresented: Bool
    
    /// The offset for the view.
    @State private var offset: CGFloat = UIScreen.main.bounds.height
    
    /// A flag indicating if the view is being dragged.
    @State private var isDragging = false
    
    /// A flag indicating if the email signup view should be shown.
    @State private var showEmailSignUp = false
    
    /// A flag indicating if the password reset view should be shown.
    @State private var showPasswordReset = false
    
    /// A flag indicating whether validation errors should be shown.
    @State private var showValidationErrors = false
    
    // Validation states
    private var isEmailValid: Bool { !viewModel.email.isEmpty }
    private var isPasswordValid: Bool { !viewModel.password.isEmpty }
    private var isFormValid: Bool { isEmailValid && isPasswordValid }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            // Semi-transparent background
            Color.black
                .opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissCard()
                }
            
            // Card View
            VStack(spacing: 0) {
                // Handle indicator
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 50, height: 5)
                    .cornerRadius(2.5)
                    .padding(.top, 12)
                    .padding(.bottom, 30)
                
                // Content
                ScrollView {
                    VStack(spacing: 25) {
                        // Title and description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Login to CycleMate")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Welcome back! Please enter your details to continue.")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                        
                        // Form fields with validation
                        VStack(spacing: 20) {
                            // Email field
                            TextField("Email", text: $viewModel.email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(showValidationErrors && !isEmailValid ? Color.red : Color.gray, lineWidth: 1)
                                )
                            
                            if showValidationErrors && !isEmailValid {
                                Text("Please enter your email")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            // Password field
                            SecureField("Password", text: $viewModel.password)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(showValidationErrors && !isPasswordValid ? Color.red : Color.gray, lineWidth: 1)
                                )
                            
                            if showValidationErrors && !isPasswordValid {
                                Text("Please enter your password")
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        // Forgot password button
                        Button {
                            showPasswordReset = true
                        } label: {
                            Text("Forgot Password?")
                                .foregroundColor(Color("second"))
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        // Create account section
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.gray)
                            Button {
                                showEmailSignUp = true
                            } label: {
                                Text("Sign Up")
                                    .foregroundColor(Color("second"))
                                    .fontWeight(.semibold)
                            }
                        }
                        .font(.subheadline)
                    }
                    .padding(.horizontal, 25)
                }
                
                // Login button
                Button {
                    if isFormValid {
                        Task {
                            await signInUser()
                        }
                    } else {
                        withAnimation {
                            showValidationErrors = true
                        }
                    }
                } label: {
                    Text("Login")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isFormValid ? Color("second") : Color.gray.opacity(0.3))
                        .cornerRadius(30)
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 20)
                .background(Color(.systemBackground))
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
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $showEmailSignUp) {
            EmailSignUpView()
        }
        .sheet(isPresented: $showPasswordReset) {
            PasswordResetView()
        }
        .onChange(of: viewModel.userSession) { newValue in
            if newValue != nil {
                dismissCard()
                // Navigate to MainTabView after successful login
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = UIHostingController(rootView: MainTabView())
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Signs in the user with email and password.
    private func signInUser() async {
        await viewModel.signInWithEmail()
    }
    
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

// Preview
#Preview {
    EmailLoginView(isPresented: .constant(true))
}
