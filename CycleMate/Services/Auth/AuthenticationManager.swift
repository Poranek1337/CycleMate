//
//  AuthenticationManager.swift
//  CycleMate
//

// Your imports remain the same
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn
import SwiftUI
import CryptoKit

/// Manages authentication and user sessions.
@MainActor
class AuthenticationManager: ObservableObject {
    // MARK: - Properties
    static let shared = AuthenticationManager()
    
    @Published var currentUser: AuthUser?
    @Published var isAuthenticated = false
    @Published var needsProfileCompletion = false
    
    // Firebase references
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    // Add flag to prevent duplicate loading
    private var isLoadingUser = false
    
    // MARK: - Initialization
    private init() {
        print("📱 AuthenticationManager initialized")
        configureFirestore()
        setupAuthStateListener()
        // Remove initial checkAuthenticationState call
    }
    
    /// Configures Firestore for offline persistence.
    private func configureFirestore() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        db.settings = settings
    }
    
    // MARK: - Auth State Management
    /// Sets up the authentication state listener.
    private func setupAuthStateListener() {
        print("🔄 Setting up auth state listener")
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if let user = user {
                print("✅ Found user session for ID: \(user.uid)")
                Task { [weak self] in
                    guard let self = self else { return }
                    if !self.isLoadingUser {
                        self.isLoadingUser = true
                        try? await self.loadExistingUser(firebaseId: user.uid)
                        self.isLoadingUser = false
                    }
                }
            } else {
                print("❌ No user session")
                self?.clearUserState()
            }
        }
    }
    
    /// Clears the user state.
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
    
    //MARK: - Email Authentication
    func createUserWithEmailAndWaitForVerification(email: String, password: String) async throws {
        print("📧 Creating user with email: \(email)")
        
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = authResult.user
        
        // Create initial user document in Firestore
        let userData: [String: Any] = [
            "id": user.uid,
            "email": email,
            "firstName": "",
            "lastName": "",
            "photoURL": "",
            "createdAt": FieldValue.serverTimestamp(),
            "dateOfBirth": NSNull(),
            "provider": "email",
            "isProfileCompleted": false
        ]
        
        // Create user document first
        try await db.collection("users").document(user.uid).setData(userData)
        
        // Send verification email after document creation
        try await user.sendEmailVerification()
        print("✉️ Verification email sent to: \(email)")
        
        // Set current user immediately
        self.currentUser = AuthUser(
            id: user.uid,
            firstName: "",
            lastName: "",
            email: email,
            photoURL: "",
            createdAt: Date(),
            dateOfBirth: nil,
            provider: .email,
            isProfileCompleted: false
        )
        
        self.isAuthenticated = true
        self.needsProfileCompletion = true
    }
    
    // MARK: - Google Authentication
    // Rest of Google authentication methods remain the same
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
    /// Loads an existing user from Firestore.
    /// - Parameter firebaseId: The Firebase user ID.
    private func loadExistingUser(firebaseId: String) async throws {
        let document = try await db.collection("users").document(firebaseId).getDocument()
        
        guard let data = document.data(),
              let email = data["email"] as? String else {
            throw AuthError.userNotFound
        }
        
        // Handle optional fields with default values
        let firstName = data["firstName"] as? String ?? ""
        let lastName = data["lastName"] as? String ?? ""
        let photoURL = data["photoURL"] as? String ?? ""
        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        let dateOfBirth = (data["dateOfBirth"] as? Timestamp)?.dateValue()
        let isProfileCompleted = data["isProfileCompleted"] as? Bool ?? false
        
        let user = AuthUser(
            id: firebaseId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            photoURL: photoURL,
            createdAt: createdAt,
            dateOfBirth: dateOfBirth,
            provider: .email,
            isProfileCompleted: isProfileCompleted
        )
        
        self.currentUser = user
        self.isAuthenticated = true
        self.needsProfileCompletion = !isProfileCompleted
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
        
        // Generate profile color and convert to components
        let profileColor = ColorGenerator.generateProfileColor()
        let colorComponents = ColorGenerator.colorToComponents(profileColor)
        
        // Create user document in Firestore
        let userData: [String: Any] = [
            "id": authResult.user.uid,
            "firstName": firstName,
            "lastName": lastName,
            "email": authResult.user.email ?? "",
            "dateOfBirth": Timestamp(date: dateOfBirth),
            "photoURL": "",
            "createdAt": FieldValue.serverTimestamp(),
            "provider": "google",
            "isProfileCompleted": true,
            "backgroundColor": [
                "red": colorComponents.red,
                "green": colorComponents.green,
                "blue": colorComponents.blue
            ]
        ]
        
        try await db.collection("users").document(authResult.user.uid).setData(userData)
        
        // Update local user
        let updatedUser = AuthUser(
            id: authResult.user.uid,
            firstName: firstName,
            lastName: lastName,
            email: authResult.user.email,
            photoURL: "",
            createdAt: Date(),
            dateOfBirth: dateOfBirth,
            provider: .google,
            isProfileCompleted: true,
            backgroundColor: profileColor
        )
        
        self.currentUser = updatedUser
        self.isAuthenticated = true
        self.needsProfileCompletion = false
        
        // Clean up stored credentials
        UserDefaults.standard.removeObject(forKey: "google_id_token")
        UserDefaults.standard.removeObject(forKey: "google_access_token")
    }
    
    // Rest of profile management methods remain the same
    // MARK: - Profile Image Management
    func uploadProfileImage(_ image: UIImage) async throws {
        // First verify current user exists
        guard let currentFirebaseUser = Auth.auth().currentUser else {
            print("❌ No Firebase user found")
            throw AuthError.userNotFound
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to data")
            throw AuthError.imageUploadFailed
        }
        
        print("📸 Starting profile image upload for user: \(currentFirebaseUser.uid)")
        
        // First verify user document exists
        let userDoc = try await db.collection("users").document(currentFirebaseUser.uid).getDocument()
        guard userDoc.exists else {
            print("❌ User document not found in Firestore")
            throw AuthError.userNotFound
        }
        
        // Generate unique filename with timestamp
        let fileName = "\(currentFirebaseUser.uid)_\(Int(Date().timeIntervalSince1970)).jpg"
        let imageRef = storage.child("profile_images/\(fileName)")
        
        do {
            print("📤 Uploading image data...")
            _ = try await imageRef.putDataAsync(imageData)
            
            print("🔗 Getting download URL...")
            let url = try await imageRef.downloadURL()
            
            print("💾 Updating Firestore document...")
            try await db.collection("users").document(currentFirebaseUser.uid).updateData([
                "photoURL": url.absoluteString,
                "isProfileCompleted": true
            ])
            
            // Update local user state
            print("🔄 Updating local user state...")
            try await loadExistingUser(firebaseId: currentFirebaseUser.uid)
            print("✅ Profile image upload completed successfully")
        } catch {
            print("❌ Profile image upload failed with error: \(error)")
            throw AuthError.imageUploadFailed
        }
    }
    
    func checkAndUpdateProfileImage() async throws {
        guard let currentUser = currentUser,
              let photoURL = currentUser.photoURL,
              let url = URL(string: photoURL) else { return }
        
        let maxRetries = 3
        var currentRetry = 0
        
        while currentRetry < maxRetries {
            do {
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
                let (data, _) = try await URLSession.shared.data(for: request)
                
                guard let remoteImage = UIImage(data: data) else { return }
                
                if let localImage = ProfileImageManager.shared.loadLocalImage(forUserId: currentUser.id) {
                    if !ProfileImageManager.shared.areImagesEqual(localImage: localImage, remoteImage: remoteImage) {
                        let _ = try ProfileImageManager.shared.saveImageLocally(remoteImage, forUserId: currentUser.id)
                    }
                } else {
                    let _ = try ProfileImageManager.shared.saveImageLocally(remoteImage, forUserId: currentUser.id)
                }
                
                return
            } catch let error as NSError {
                if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                    currentRetry += 1
                    if currentRetry < maxRetries {
                        try await Task.sleep(for: .seconds(1))
                        continue
                    }
                }
                throw error
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            clearUserState()
            print("✅ User signed out successfully")
        } catch {
            print("❌ Failed to sign out: \(error)")
            throw AuthError.signOutFailed
        }
    }
}
