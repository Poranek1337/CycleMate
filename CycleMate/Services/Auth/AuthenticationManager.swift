//
//  AuthenticationManager.swift
//  CycleMate
//

import SwiftUI

/// Manages authentication and user sessions.
@MainActor
class AuthenticationManager: ObservableObject {
    // MARK: - Properties
    static let shared = AuthenticationManager()
    
    @Published var currentUser: AuthUser?
    @Published var isAuthenticated = false
    @Published var needsProfileCompletion = false
    
    private var isLoadingUser = false
    
    // MARK: - Initialization
    private init() {
        print("📱 AuthenticationManager initialized")
        checkAuthenticationState()
    }
    
    // MARK: - Auth State Management
    private func checkAuthenticationState() {
        // Używamy bezpośrednio sprawdzenia czy token istnieje
        if UserDefaults.standard.string(forKey: "auth_token") != nil {
            self.isAuthenticated = true
            if let userData = UserDefaults.standard.data(forKey: "user_data"),
               let user = try? JSONDecoder().decode(AuthUser.self, from: userData) {
                self.currentUser = user
                self.needsProfileCompletion = !user.isProfileCompleted
            }
        }
    }
    
    private func clearUserState() {
        print("🧹 Clearing user state")
        Task { @MainActor in
            self.currentUser = nil
            self.isAuthenticated = false
            self.needsProfileCompletion = false
            UserDefaults.standard.removeObject(forKey: "auth_token")
            UserDefaults.standard.removeObject(forKey: "user_data")
        }
    }
    
    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "auth_token")
        UserDefaults.standard.synchronize()
        print("✅ Token saved: \(token)")
    }
    
    // MARK: - Token Management
    private func getStoredToken() -> String? {
        let token = UserDefaults.standard.string(forKey: "auth_token")
        print("🔑 Retrieved token from UserDefaults: \(token ?? "nil")")
        return token
    }
    
    // MARK: - Profile Image Management
    func uploadProfileImage(_ image: UIImage) async throws {
        print("🔄 Starting profile image upload")
        
        guard let token = getStoredToken() else {
            print("❌ No token found in UserDefaults")
            throw AuthError.userNotFound
        }
        
        do {
            print("📤 Attempting to upload image with token: \(token)")
            let imageUrl = try await ProfileImageManager.shared.uploadProfileImage(image, token: token)
            print("✅ Image uploaded successfully, URL: \(imageUrl)")
            
            if var currentUser = self.currentUser {
                currentUser.photoURL = imageUrl
                currentUser.isProfileCompleted = true
                
                await MainActor.run {
                    self.currentUser = currentUser
                    if let encodedData = try? JSONEncoder().encode(currentUser) {
                        UserDefaults.standard.set(encodedData, forKey: "user_data")
                        UserDefaults.standard.synchronize()
                    }
                }
            }
            
        } catch {
            print("❌ Upload failed: \(error)")
            throw error
        }
    }
    
    func validateStoredToken() async throws {
        // Pobieramy token i faktycznie go używamy do walidacji
        guard let token = getStoredToken() else {
            throw AuthError.userNotFound
        }
        
        // TODO: Dodać faktyczną implementację walidacji tokena
        // Na razie tylko sprawdzamy czy token istnieje
        print("🔑 Validating token: \(token)")
    }
    
    // MARK: - Auth Error
    enum AuthError: Error {
        case userNotFound
        case imageUploadFailed
        case signOutFailed
    }
}
