//
//  PasswordResetView.swift
//  CycleMate
//  dev.Poranek
//

import SwiftUI
import Firebase
import FirebaseAuth

/// A view that handles password reset functionality.
struct PasswordResetView: View {
    // MARK: - Properties
    
    /// The environment dismiss action.
    @Environment(\.dismiss) private var dismiss
    
    /// The email address for password reset.
    @State private var email = ""
    
    /// A flag indicating if an error should be shown.
    @State private var showError = false
    
    /// The error message to display.
    @State private var errorMessage = ""
    
    /// A flag indicating if the success message should be shown.
    @State private var showSuccess = false
    
    /// A flag indicating whether validation errors should be shown.
    @State private var showValidationErrors = false
    
    // Validation states
    private var isEmailValid: Bool { !email.isEmpty }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Reset Password")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top)
                
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                
                VStack(spacing: 8) {
                    TextField("Email", text: $email)
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
                }
                .padding(.horizontal)
                
                Button {
                    if isEmailValid {
                        resetPassword()
                    } else {
                        withAnimation {
                            showValidationErrors = true
                        }
                    }
                } label: {
                    Text("Send Reset Link")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isEmailValid ? Color("second") : Color.gray.opacity(0.3))
                        .cornerRadius(30)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Password reset link has been sent to your email.")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Sends a password reset email.
    private func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                showSuccess = true
            }
        }
    }
}

// Preview
#Preview {
    PasswordResetView()
}
