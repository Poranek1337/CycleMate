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
    @ObservedObject private var viewModel: AuthViewModel
    
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
    @State private var showProfilePicture = false
    
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
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Header section
                        HStack(alignment: .top) {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Title and description
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
                        
                        // Form fields with validation
                        VStack(spacing: 20) {
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
                            
                            // Date button
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
                        .padding(.horizontal)
                        .padding(.top, 30)
                    }
                }
                
                // Bottom section with checkboxes and button
                VStack(spacing: 15) {
                    // Terms checkbox
                    Button {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            termsAccepted.toggle()
                        }
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            // Checkbox with validation
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(showValidationErrors && !isTermsAccepted ? Color.red : (termsAccepted ? Color("second") : Color.gray), lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                
                                if termsAccepted {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color("second"))
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            
                            // Terms text
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
                    
                    // Newsletter checkbox
                    Button {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                            newsletterAccepted.toggle()
                        }
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            // Checkbox
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
                            
                            // Newsletter text
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
                    
                    // Continue button
                    Button {
                        if isFormValid {
                            Task {
                                await viewModel.completeUserProfile()
                                if !viewModel.showError {
                                    showProfilePicture = true
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
                .padding()
                .background(Color(.systemBackground))
            }
            
            // Floating calendar overlay
            if showDatePicker {
                // Semi-transparent background
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showDatePicker = false
                        }
                    }
                
                // Calendar picker
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
                    
                    // Done button
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
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateContent = true
            }
        }
        .fullScreenCover(isPresented: $showProfilePicture) {
            ProfilePictureView(viewModel: viewModel)
                .interactiveDismissDisabled(true)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// Preview
#Preview {
    UserDataFormView(viewModel: AuthViewModel())
}