import SwiftUI
import Firebase
import FirebaseAuth

/// A view that handles email login.
struct EmailLoginView: View {
    // MARK: - Properties
    
    /// The view model for authentication.
    @EnvironmentObject private var viewModel: AuthViewModel
    
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
    
    @State private var keyboardHeight: CGFloat = 0
    
    private var isEmailValid: Bool { !viewModel.email.isEmpty }
    private var isPasswordValid: Bool { !viewModel.password.isEmpty }
    private var isFormValid: Bool { isEmailValid && isPasswordValid }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
                .opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissCard()
                }
            
            VStack(alignment: .leading, spacing: 0) {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 50, height: 5)
                    .cornerRadius(2.5)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Login to CycleMate")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Welcome back! Please enter your details to continue.")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.bottom, 2)
                    
                    VStack(spacing: 10) {
                        TextField("Email", text: $viewModel.email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(showValidationErrors && !isEmailValid ? Color.red : Color.gray, lineWidth: 1)
                            )
                        
                        if showValidationErrors && !isEmailValid {
                            Text("Please enter your email")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.bottom, -5)
                        }
                        
                        SecureField("Password", text: $viewModel.password)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(showValidationErrors && !isPasswordValid ? Color.red : Color.gray, lineWidth: 1)
                            )
                        
                        if showValidationErrors && !isPasswordValid {
                            Text("Please enter your password")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.bottom, -5)
                        }
                    }
                    
                    Button {
                        showPasswordReset = true
                    } label: {
                        Text("Forgot Password?")
                            .foregroundColor(Color("second"))
                            .font(.subheadline)
                    }
                    .padding(.top, 2)
                    
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
                    .frame(maxWidth: .infinity)
                    .font(.subheadline)
                    .padding(.top, 2)
                    
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
                            .padding(.vertical, 14)
                            .background(isFormValid ? Color("second") : Color.gray.opacity(0.3))
                            .cornerRadius(30)
                    }
                    .padding(.top, 40)
                }
                .padding(.horizontal, 25)
                .padding(.top, 5)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height / 2.0)
            .background(Color(.systemBackground))
            .cornerRadius(25, corners: [.topLeft, .topRight])
            .offset(y: offset)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: keyboardHeight)
            .offset(y: keyboardHeight > 0 ? -keyboardHeight/2 : 0)
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
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        keyboardHeight = keyboardFrame.height
                    }
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    keyboardHeight = 0
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
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
        .onChange(of: viewModel.userSession) { oldValue, newValue in
            if newValue != nil {
                dismissCard()
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
        .environmentObject(AuthViewModel())
}
