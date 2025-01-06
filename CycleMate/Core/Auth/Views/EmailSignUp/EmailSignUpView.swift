//
//  EmailSignUpView.swift
//  CycleMate
//  dev.Poranek
//

import SwiftUI
import Firebase
import FirebaseAuth

/// A view that handles email sign up and verification.
struct EmailSignUpView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AuthViewModel()
    
    // Animation and UI states
    @State private var animateContent = false
    @State private var showDatePicker = false
    @State private var dateSelected = false
    @State private var termsAccepted = false
    @State private var newsletterAccepted = false
    @State private var showValidationErrors = false
    @State private var showVerificationPopup = false
    @State private var showProfilePictureView = false
    
    // Form fields
    @State private var email = ""
    @State private var password = ""
    
    // Verification states
    @State private var verificationStatus: VerificationStatus = .initial
    @State private var isVerifying = false
    
    // MARK: - Validation Logic
    private var isFirstNameValid: Bool { !viewModel.firstName.isEmpty }
    private var isLastNameValid: Bool { !viewModel.lastName.isEmpty }
    private var isDateValid: Bool { dateSelected }
    private var isTermsAccepted: Bool { termsAccepted }
    private var isEmailValid: Bool { email.contains("@") && email.contains(".") }
    private var isPasswordValid: Bool { password.count >= 6 }
    
    private var isFormValid: Bool {
        isFirstNameValid &&
        isLastNameValid &&
        isDateValid &&
        isTermsAccepted &&
        isEmailValid &&
        isPasswordValid
    }
    
    // MARK: - Types
    private enum VerificationStatus {
        case initial
        case verifying
        case success
        case failed
    }
    
    // MARK: - View Components
    private var headerSection: some View {
        HStack(alignment: .top) {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Create your account")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Please fill in the details below to set up your CycleMate account.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
    
    private var formSection: some View {
        VStack(spacing: 20) {
            // Email field
            emailField
            
            // Password field
            passwordField
            
            // Name fields
            nameFields
            
            // Date of birth
            dateOfBirthButton
        }
        .padding(.horizontal)
        .padding(.top, 30)
    }
    
    private var emailField: some View {
        VStack(spacing: 5) {
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
                Text("Please enter a valid email address")
                    .foregroundColor(.red)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var passwordField: some View {
        VStack(spacing: 5) {
            SecureField("Password", text: $password)
                .textInputAutocapitalization(.never)
                .textContentType(.newPassword)
                .padding()
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(showValidationErrors && !isPasswordValid ? Color.red : Color.gray, lineWidth: 1)
                )
            
            if showValidationErrors && !isPasswordValid {
                Text("Password must be at least 6 characters long")
                    .foregroundColor(.red)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var nameFields: some View {
        VStack(spacing: 20) {
            // First name
            VStack(spacing: 5) {
                TextField("First name", text: $viewModel.firstName)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(showValidationErrors && !isFirstNameValid ? Color.red : Color.gray, lineWidth: 1)
                    )
                
                if showValidationErrors && !isFirstNameValid {
                    Text("Please enter your first name")
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            // Last name
            VStack(spacing: 5) {
                TextField("Last name", text: $viewModel.lastName)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(showValidationErrors && !isLastNameValid ? Color.red : Color.gray, lineWidth: 1)
                    )
                
                if showValidationErrors && !isLastNameValid {
                    Text("Please enter your last name")
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    private var dateOfBirthButton: some View {
        VStack(spacing: 5) {
            Button {
                withAnimation(.spring()) {
                    showDatePicker.toggle()
                }
            } label: {
                HStack {
                    if !dateSelected {
                        Text("Date of birth")
                            .foregroundColor(.gray)
                    } else {
                        Text(viewModel.dateOfBirth.formatted(date: .long, time: .omitted))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(showValidationErrors && !isDateValid ? Color.red : Color.gray, lineWidth: 1)
                )
            }
            
            if showValidationErrors && !isDateValid {
                Text("Please select your date of birth")
                    .foregroundColor(.red)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var bottomSection: some View {
        VStack(spacing: 15) {
            termsCheckbox
            newsletterCheckbox
            continueButton
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var termsCheckbox: some View {
        Button {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                termsAccepted.toggle()
            }
        } label: {
            HStack(alignment: .top, spacing: 10) {
                checkboxView(isChecked: termsAccepted, showError: showValidationErrors && !isTermsAccepted)
                termsText
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var termsText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("I acknowledge and agree to CycleMate's ")
                .foregroundColor(.gray) +
            Text("Terms of Service")
                .foregroundColor(Color("second")) +
            Text(" and ")
                .foregroundColor(.gray) +
            Text("Privacy Policy")
                .foregroundColor(Color("second")) +
            Text(". I understand that CycleMate will process my personal data as described in the Privacy Policy.")
                .foregroundColor(.gray)
        }
        .font(.subheadline)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private var newsletterCheckbox: some View {
        Button {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                newsletterAccepted.toggle()
            }
        } label: {
            HStack(alignment: .top, spacing: 10) {
                checkboxView(isChecked: newsletterAccepted, showError: false)
                newsletterText
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var newsletterText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("(Optional) Keep me updated")
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Text("I would like to receive emails about product updates, feature announcements, and cycling tips. You can unsubscribe at any time.")
                .foregroundColor(.gray)
        }
        .font(.subheadline)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private func checkboxView(isChecked: Bool, showError: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .stroke(showError ? Color.red : (isChecked ? Color("second") : Color.gray), lineWidth: 2)
                .frame(width: 24, height: 24)
            
            if isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("second"))
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    private var continueButton: some View {
        Button(action: handleContinueButton) {
            Text("Continue")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isFormValid ? Color("second") : Color.gray.opacity(0.3))
                .cornerRadius(30)
        }
    }
    
    private func handleContinueButton() {
        if isFormValid {
            Task {
                verificationStatus = .verifying
                showVerificationPopup = true
                await viewModel.sendVerificationEmail(email: email, password: password)
                await checkVerification()
            }
        } else {
            withAnimation {
                showValidationErrors = true
            }
        }
    }
    
    private func checkVerification() async {
        for _ in 0..<60 { // Check for 5 minutes
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            if let user = Auth.auth().currentUser {
                try? await user.reload()
                if user.isEmailVerified {
                    withAnimation {
                        verificationStatus = .success
                    }
                    return
                }
            }
        }
        verificationStatus = .failed
    }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        headerSection
                        titleSection
                        formSection
                    }
                }
                bottomSection
            }
            
            if showDatePicker {
                datePickerOverlay
            }
            
            if showVerificationPopup {
                verificationPopupOverlay
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateContent = true
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .fullScreenCover(isPresented: $showProfilePictureView) {
            ProfilePictureView(viewModel: viewModel)
        }
    }
    
    private var datePickerOverlay: some View {
        ZStack {
            Color.black
                .opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring()) {
                        showDatePicker = false
                    }
                }
            
            VStack {
                DatePicker(
                    "Select date",
                    selection: Binding(
                        get: { viewModel.dateOfBirth },
                        set: { date in
                            viewModel.dateOfBirth = date
                            dateSelected = true
                        }
                    ),
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                .tint(Color("second"))
                
                Button {
                    withAnimation(.spring()) {
                        showDatePicker = false
                    }
                } label: {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 30)
                        .background(Color("second"))
                        .cornerRadius(20)
                }
                .padding(.bottom)
            }
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 10)
            .frame(width: UIScreen.main.bounds.width - 40)
            .transition(.scale.combined(with: .opacity))
            .zIndex(1)
        }
    }
    
    private var verificationPopupOverlay: some View {
        ZStack {
            Color.black
                .opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                verificationStatusIcon
                
                Text(verificationStatus == .success ? "Email Verified!" : "Verification Email Sent")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("We've sent a verification email to \(email). Please check your inbox and click the verification link to complete your registration.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                verificationActionButton
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 10)
            .frame(width: UIScreen.main.bounds.width - 40)
            .transition(.scale.combined(with: .opacity))
            .zIndex(2)
        }
    }
    
    private var verificationStatusIcon: some View {
        ZStack {
            if verificationStatus == .verifying {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .frame(width: 60, height: 60)
            } else if verificationStatus == .success {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Image(systemName: "envelope.circle.fill")
                    .font(.system(size: 60))
            }
        }
        .foregroundColor(Color("second"))
        .padding()
    }
    
    private var verificationActionButton: some View {
        Button {
            if verificationStatus == .success {
                Task {
                    do {
                        try await viewModel.createVerifiedUser(email: email, password: password)
                        showProfilePictureView = true
                    } catch {
                        print("❌ Failed to create verified user: \(error)")
                        viewModel.errorMessage = "Failed to complete registration. Please try again."
                        viewModel.showError = true
                    }
                }
            }
        } label: {
            Text(verificationStatus == .success ? "Continue" : "Verifying...")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 30)
                .background(verificationStatus == .success ? Color("second") : Color.gray)
                .cornerRadius(20)
        }
        .disabled(verificationStatus != .success)
    }
}

// MARK: - Preview
#Preview {
    EmailSignUpView()
}
