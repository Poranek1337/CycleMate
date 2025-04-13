//
//  UserDataFormView.swift
//  CycleMate
//  dev.Poranek
//

import SwiftUI

/// A view that handles user data form for profile setup.
struct UserDataFormView: View {
    // MARK: - Properties
    
    /// The environment dismiss action.
    @Environment(\.dismiss) private var dismiss
    
    /// The view model for authentication.
    @StateObject private var viewModel: AuthViewModel
    
    /// A flag indicating if the content should be animated.
    @State private var animateContent = false
    
    /// A flag indicating if the date picker should be shown.
    @State private var showDatePicker = false
    
    /// A flag indicating if the date has been selected.
    @State private var dateSelected = false
    
    /// A flag indicating if the terms have been accepted.
    @State private var termsAccepted = false
    
    /// A flag indicating if the newsletter has been accepted.
    @State private var newsletterAccepted = false
    
    /// A flag indicating if validation errors should be shown.
    @State private var showValidationErrors = false
    
    /// A flag indicating if the profile picture view should be shown.
    @State private var showProfilePictureView = false
    
    // Validation states
    private var isFirstNameValid: Bool { !viewModel.firstName.isEmpty }
    private var isLastNameValid: Bool { !viewModel.lastName.isEmpty }
    private var isDateValid: Bool { dateSelected }
    private var isTermsAccepted: Bool { termsAccepted }
    private var isFormValid: Bool { isFirstNameValid && isLastNameValid && isDateValid && isTermsAccepted }
    
    // MARK: - Initialization
    
    /// Initializes a new instance of `UserDataFormView`.
    /// - Parameter viewModel: The view model for authentication.
    init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .center) {
            mainContent
            if showDatePicker {
                datePickerOverlay
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateContent = true
            }
        }
        .fullScreenCover(isPresented: $showProfilePictureView) {
            ProfilePictureView(viewModel: viewModel)
                .interactiveDismissDisabled(true)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    // MARK: - View Components
    
    private var mainContent: some View {
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
    }

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
            Text("Set up your profile ")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Please fill in the details below to complete your profile. To use the app, please fill in your details. ")
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
            firstNameField
            lastNameField
            dateOfBirthField
        }
        .padding(.horizontal)
        .padding(.top, 30)
    }

    private var firstNameField: some View {
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
    }

    private var lastNameField: some View {
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

    private var dateOfBirthField: some View {
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
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(showValidationErrors && !termsAccepted ? Color.red : (termsAccepted ? Color("second") : Color.gray), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if termsAccepted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color("second"))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                
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
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var newsletterCheckbox: some View {
        Button {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                newsletterAccepted.toggle()
            }
        } label: {
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(newsletterAccepted ? Color("second") : Color.gray, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if newsletterAccepted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color("second"))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                
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
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var continueButton: some View {
        Button {
            if isFormValid {
                Task {
                    do {
                        try await viewModel.completeUserProfile()
                        await MainActor.run {
                            showProfilePictureView = true
                        }
                    } catch {
                        await MainActor.run {
                            viewModel.errorMessage = "Failed to update profile. Please try again."
                            viewModel.showError = true
                        }
                    }
                }
            } else {
                withAnimation {
                    showValidationErrors = true
                }
            }
        } label: {
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
        }
    }
}

// Preview
struct UserDataFormView_Previews: PreviewProvider {
    static var previews: some View {
        UserDataFormView(viewModel: AuthViewModel())
    }
}
