//
//  AuthViewModel.swift
//  CycleMate
//  dev.Poranek
//

import SwiftUI
import GoogleSignIn
import Firebase
import FirebaseAuth

/// ViewModel responsible for handling authentication logic.
@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// The current user session.
    @Published var userSession: FirebaseAuth.User?
    
    /// The current user.
    @Published var currentUser: User?
    
    /// A flag indicating whether to show email authentication view.
    @Published var showEmailAuth = false
    
    /// A flag indicating whether to show an error message.
    @Published var showError = false
    
    /// The error message to display.
    @Published var errorMessage = ""
    
    /// A flag indicating whether to show the user data form.
    @Published var showUserDataForm = false
    
    /// The user's profile image.
    @Published var userProfileImage: UIImage?

    // Email auth properties
    @Published var email = ""
    @Published var password = ""

    // User input fields
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var dateOfBirth = Date()

    // MARK: - Private Properties
    
    /// The authentication manager.
    let authManager = AuthenticationManager.shared

    /// Initializes a new instance of `AuthViewModel`.
    init() {
        print("📱 AuthViewModel initialized")
        setupAuthStateListener()
        updateUserState()
        Task {
            await fetchUser()
        }
    }

    /// Sets up the authentication state listener.
    private func setupAuthStateListener() {
        print("🔄 Setting up auth state listener in AuthViewModel")
        authManager.objectWillChange.sink { [weak self] _ in
            Task { @MainActor in
                if let currentAuthUser = self?.authManager.currentUser {
                    print("✅ Received user update in AuthViewModel")
                    print("👤 User ID: \(currentAuthUser.id)")
                    self?.userSession = Auth.auth().currentUser
                    self?.currentUser = User(from: currentAuthUser)
                    print("🔄 Updated currentUser in AuthViewModel")
                }
            }
        }
    }

    /// Updates the user state based on the current authentication state.
    private func updateUserState() {
        if let authUser = authManager.currentUser {
            self.userSession = Auth.auth().currentUser
            self.currentUser = User(from: authUser)
        } else {
            self.userSession = nil
            self.currentUser = nil
        }
    }

    // MARK: - Authentication Methods
    
    /// Fetches the current user data.
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
    }

    /// Signs in the user with email and password.
    func signInWithEmail() async {
        do {
            // Add your email sign in logic here
            print(" Attempting email sign in")
            // try await authManager.signInWithEmail(email: email, password: password)
        } catch {
            print(" Email Sign In failed: \(error)")
            errorMessage = "Failed to sign in with email. Please try again."
            showError = true
        }
    }

    /// Signs in the user with Google.
    func signInWithGoogle() async throws {
        print("🔵 Starting Google Sign In from ViewModel")
        do {
            try await authManager.signInWithGoogle()
            print("✅ Google Sign In completed in AuthViewModel")
            
            if let user = Auth.auth().currentUser {
                print("👤 User found in AuthViewModel: \(user.uid)")
                self.userSession = user
                
                // Check if user exists in Firestore
                let userRef = Firestore.firestore().collection("users").document(user.uid)
                let document = try await userRef.getDocument()
                
                if document.exists {
                    print("✅ User exists in Firestore")
                    self.currentUser = try document.data(as: User.self)
                    await fetchUser() // Refresh user data
                    return // Return early as user exists
                } 
                
                // Handle new user
                print("⚠️ New user - needs profile completion")
                if let displayName = user.displayName {
                    let names = displayName.split(separator: " ")
                    firstName = String(names.first ?? "")
                    lastName = names.count > 1 ? String(names.last ?? "") : ""
                }
                showUserDataForm = true
            } else {
                print("❌ No user found after Google Sign In")
                throw AuthError.signInFailed
            }
        } catch {
            print("❌ Google Sign In failed: \(error)")
            throw error
        }
    }

    // MARK: - Profile Management Methods
    
    /// Completes the user profile with additional information.
    func completeUserProfile() async {
        print(" Completing user profile")
        do {
            try await authManager.updateUserProfile(
                firstName: firstName,
                lastName: lastName,
                dateOfBirth: dateOfBirth
            )
            await fetchUser()
            print(" Profile completed successfully")
        } catch {
            print(" Profile completion failed: \(error)")
            errorMessage = "Failed to complete profile. Please try again."
            showError = true
        }
    }

    // MARK: - Profile Image Methods
    
    /// Updates the user's profile image.
    /// - Parameter image: The new profile image.
    func updateProfileImage(image: UIImage) async {
        do {
            userProfileImage = image
            try await authManager.uploadProfileImage(image)
            await fetchUser()
            print(" Profile image updated successfully")
            showUserDataForm = false
        } catch {
            print(" Profile image update failed: \(error)")
            errorMessage = "Failed to update profile image. Please try again."
            showError = true
        }
    }

    // MARK: - Sign Out
    
    /// Signs out the current user.
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("Failed to sign out: \(error.localizedDescription)")
        }
    }

    // MARK: - Helper Methods
    
    /// Resets the error state.
    func resetErrors() {
        showError = false
        errorMessage = ""
    }

    /// Resets the form fields.
    func resetForm() {
        firstName = ""
        lastName = ""
        dateOfBirth = Date()
        email = ""
        password = ""
        userProfileImage = nil
    }

    /// Enumeration of possible authentication errors.
    enum AuthError: Error {
        case signInFailed
        case userNotFound
        case profileUpdateFailed
    }
}