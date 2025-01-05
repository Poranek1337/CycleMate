//
//  EmailAuthView.swift
//  CycleMate
//  dev.Poranek
//

import SwiftUI

/// A view that handles email authentication.
struct EmailAuthView: View {
    /// The environment dismiss action.
    @Environment(\.dismiss) private var dismiss
    
    /// The view model for authentication.
    @StateObject private var viewModel = AuthViewModel()
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            // Email text field
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            // Password text field
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Sign in button
            Button {
                Task {
                    await viewModel.signInWithEmail()
                }
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("second"))
                    .cornerRadius(15)
            }
        }
        .padding()
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// Preview remains the same
#Preview {
    EmailAuthView()
}