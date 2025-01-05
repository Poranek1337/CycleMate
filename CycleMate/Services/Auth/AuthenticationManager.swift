//
//  AuthenticationManager.swift
//  CycleMate
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn
import SwiftUI




// MARK: - Properties and Types
@MainActor
class AuthenticationManager: ObservableObject {
    // Singleton instance
    static let shared = AuthenticationManager()
    
    // Published properties
    @Published var currentUser: AuthUser?
    @Published var isAuthenticated = false
    @Published var needsProfileCompletion = false
    
    // Firebase references
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    // MARK: - Initialization
    private init() {
        print("📱 AuthenticationManager initialized")
        configureFirestore()
        setupAuthStateListener()
        checkAuthenticationState()
    }
    
    // Configure Firestore for offline persistence
    private func configureFirestore() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        db.settings = settings
    }
    
    // MARK: - Auth State Management
    private func setupAuthStateListener() {
        print("🔄 Setting up auth state listener")
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if let user = user {
                print("👤 User session exists: \(user.uid)")
                Task { [weak self] in
                    try? await self?.loadExistingUser(firebaseId: user.uid)
                }
            } else {
                print("❌ No user session")
                self?.clearUserState()
            }
        }
    }
    
    private func clearUserState() {
        print("🧹 Clearing user state")
        Task { @MainActor in
            self.currentUser = nil
            self.isAuthenticated = false
            self.needsProfileCompletion = false
            
            // Clear all authentication related data
            UserDefaults.standard.removeObject(forKey: "google_id_token")
            UserDefaults.standard.removeObject(forKey: "google_access_token")
        }
    }
    
    // MARK: - Authentication State
    private func checkAuthenticationState() {
        if let firebaseUser = Auth.auth().currentUser {
            print("🔄 Restoring existing session for user: \(firebaseUser.uid)")
            Task {
                try? await loadExistingUser(firebaseId: firebaseUser.uid)
            }
        }
    }
    
    // MARK: - Google Authentication
    func signInWithGoogle() async throws {
        print("🔵 Starting Google Sign In process")
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("❌ No client ID found")
            throw AuthError.signInFailed
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("❌ No root view controller found")
            throw AuthError.signInFailed
        }
        
        do {
            print("🔄 Attempting Google Sign In...")
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString,
                  let email = result.user.profile?.email else {
                print("❌ No ID token or email found")
                throw AuthError.signInFailed
            }
            
            let accessToken = result.user.accessToken.tokenString
            
            // Store Google credentials
            UserDefaults.standard.set(idToken, forKey: "google_id_token")
            UserDefaults.standard.set(accessToken, forKey: "google_access_token")
            
            // Create Firebase credential
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )
            
            // Try to sign in to Firebase
            let authResult = try await Auth.auth().signIn(with: credential)
            let firebaseId = authResult.user.uid
            
            // Check if user exists in Firestore
            let userDocument = try await db.collection("users").document(firebaseId).getDocument()
            
            if userDocument.exists {
                // User exists, load their data
                print("✅ Existing user found, loading profile")
                try await loadExistingUser(firebaseId: firebaseId)
                self.needsProfileCompletion = false
            } else {
                // New user, create temporary profile
                print("📝 New user, needs profile completion")
                let tempUser = AuthUser(
                    id: firebaseId,
                    firstName: result.user.profile?.givenName,
                    lastName: result.user.profile?.familyName,
                    email: email,
                    photoURL: result.user.profile?.imageURL(withDimension: 200)?.absoluteString,
                    createdAt: Date(),
                    dateOfBirth: nil,
                    provider: .google,
                    isProfileCompleted: false
                )
                
                self.currentUser = tempUser
                self.needsProfileCompletion = true
            }
            
        } catch {
            print("❌ Google Sign In failed: \(error)")
            throw AuthError.signInFailed
        }
    }
    
    // MARK: - Profile Management
    private func loadExistingUser(firebaseId: String) async throws {
        // Enable offline data persistence for this query
        let document = try await db.collection("users").document(firebaseId)
            .getDocument(source: .default)
        
        guard let data = document.data(),
              let firstName = data["firstName"] as? String,
              let lastName = data["lastName"] as? String,
              let email = data["email"] as? String,
              let dateOfBirth = data["dateOfBirth"] as? Timestamp,
              let photoURL = data["photoURL"] as? String,
              let createdAt = data["createdAt"] as? Timestamp,
              let isProfileCompleted = data["isProfileCompleted"] as? Bool else {
            throw AuthError.userNotFound
        }
        
        let user = AuthUser(
            id: firebaseId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            photoURL: photoURL,
            createdAt: createdAt.dateValue(),
            dateOfBirth: dateOfBirth.dateValue(),
            provider: .google,
            isProfileCompleted: isProfileCompleted
        )
        
        self.currentUser = user
        self.isAuthenticated = true
        self.needsProfileCompletion = false
    }
    
    func updateUserProfile(firstName: String, lastName: String, dateOfBirth: Date) async throws {
        print("👤 Updating user profile")
        
        // Get stored tokens
        guard let idToken = UserDefaults.standard.string(forKey: "google_id_token"),
              let accessToken = UserDefaults.standard.string(forKey: "google_access_token") else {
            throw AuthError.signInFailed
        }
        
        // Create Firebase credential
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )
        
        // Now create Firebase account
        let authResult = try await Auth.auth().signIn(with: credential)
        let firebaseId = authResult.user.uid
        
        // Create user document in Firestore
        let userData: [String: Any] = [
            "id": firebaseId,
            "firstName": firstName,
            "lastName": lastName,
            "email": authResult.user.email ?? "",
            "dateOfBirth": Timestamp(date: dateOfBirth),
            "photoURL": "",
            "createdAt": FieldValue.serverTimestamp(),
            "provider": "google",
            "isProfileCompleted": true
        ]
        
        try await db.collection("users").document(firebaseId).setData(userData)
        
        // Update local user
        let updatedUser = AuthUser(
            id: firebaseId,
            firstName: firstName,
            lastName: lastName,
            email: authResult.user.email,
            photoURL: "",
            createdAt: Date(),
            dateOfBirth: dateOfBirth,
            provider: .google,
            isProfileCompleted: true
        )
        
        self.currentUser = updatedUser
        self.isAuthenticated = true
        self.needsProfileCompletion = false
        
        // Clean up stored credentials
        UserDefaults.standard.removeObject(forKey: "google_id_token")
        UserDefaults.standard.removeObject(forKey: "google_access_token")
    }
    
    // MARK: - Profile Image Management
    func uploadProfileImage(_ image: UIImage) async throws {
        guard let user = currentUser else { throw AuthError.userNotFound }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw AuthError.imageUploadFailed
        }
        
        let fileName = "\(user.id)_profile.jpg"
        let imageRef = storage.child("profile_images/\(fileName)")
        
        _ = try await imageRef.putDataAsync(imageData)
        let url = try await imageRef.downloadURL()
        
        try await db.collection("users").document(user.id).updateData([
            "photoURL": url.absoluteString
        ])
        
        var updatedUser = user
        updatedUser.photoURL = url.absoluteString
        self.currentUser = updatedUser
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        do {
            // Clear local state first
            clearUserState()
            
            // Sign out from Firebase
            try Auth.auth().signOut()
            
            // Sign out from Google
            GIDSignIn.sharedInstance.signOut()
            
            print("✅ User signed out successfully")
        } catch {
            print("❌ Failed to sign out: \(error)")
            throw AuthError.signOutFailed
        }
    }
}
