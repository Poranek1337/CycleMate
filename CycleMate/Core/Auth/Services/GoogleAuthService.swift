//
//  GoogleAuthService.swift
//  CycleMate
//
//  Created by Poranek on 12/04/2025.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth
import Firebase
import AuthenticationServices

class GoogleAuthService: SocialAuthenticationProtocol {
    static let shared = GoogleAuthService()
    private let apiService = APIService()
    
    // MARK: - SocialAuthenticationProtocol
    func signIn(presenting viewController: UIViewController) async throws -> User {
        print("🔵 Starting Google Sign In process")
        
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BackendBaseURL") as? String else {
            throw AuthError.networkError("Missing base URL configuration")
        }
        
        // 1. Generuj state dla bezpieczeństwa
        let state = UUID().uuidString
        
        // 2. Utwórz URL do OAuth2 z state
        let authURL = URL(string: "\(baseURL)/oauth2/authorization/google?state=\(state)")!
        print("🌐 Starting OAuth flow with URL: \(authURL)")
        
        // 3. Wykonaj OAuth2 flow
        let token = try await performOAuth2Authentication(authURL: authURL, expectedState: state)
        print("✅ Received JWT token")
        
        // 4. Zweryfikuj token i pobierz dane użytkownika
        guard let authResponse = try? await apiService.validateToken(token) else {
            throw AuthError.invalidResponse
        }
        
        // 5. Pobierz pełny profil użytkownika
        let user = try await fetchUserProfile(with: authResponse)
        print("✅ User profile fetched successfully")
        
        return user
    }
    
    // MARK: - Private Helpers
    private func performOAuth2Authentication(authURL: URL, expectedState: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: "cyclemate"
            ) { callbackURL, error in
                if let error = error as? ASWebAuthenticationSessionError {
                    switch error.code {
                    case .canceledLogin:
                        continuation.resume(throwing: AuthError.signInFailed)
                    default:
                        continuation.resume(throwing: error)
                    }
                    return
                }
                
                guard let callbackURL = callbackURL,
                      let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false) else {
                    continuation.resume(throwing: AuthError.invalidResponse)
                    return
                }
                
                // Sprawdź state
                guard let state = components.queryItems?.first(where: { $0.name == "state" })?.value,
                      state == expectedState else {
                    continuation.resume(throwing: AuthError.invalidResponse)
                    return
                }
                
                // Pobierz token
                guard let token = components.queryItems?.first(where: { $0.name == "token" })?.value else {
                    // Sprawdź czy jest error
                    if let error = components.queryItems?.first(where: { $0.name == "error" })?.value {
                        continuation.resume(throwing: AuthError.networkError(error))
                        return
                    }
                    continuation.resume(throwing: AuthError.invalidResponse)
                    return
                }
                
                continuation.resume(returning: token)
            }
            
            session.presentationContextProvider = WindowProvider.shared
            session.prefersEphemeralWebBrowserSession = true
            
            DispatchQueue.main.async {
                session.start()
            }
        }
    }
    
    private func fetchUserProfile(with authResponse: AuthResponse) async throws -> User {
        let profileColor = ColorGenerator.generateProfileColor()
        let colorHex = ColorGenerator.colorToHexString(profileColor)
        
        return User(
            id: String(authResponse.userId),
            firstName: "",  // Będzie zaktualizowane z profilu
            lastName: "",   // Będzie zaktualizowane z profilu
            email: authResponse.email,
            photoURL: "",   // Będzie zaktualizowane z profilu
            createdAt: Date(),
            dateOfBirth: nil,
            provider: "google",
            isProfileCompleted: false,
            backgroundColor: colorHex,
            token: authResponse.token
        )
    }
}

// MARK: - Window Provider
class WindowProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = WindowProvider()
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}

// MARK: - Response Models
struct AuthStatusResponse: Codable {
    let authenticated: Bool
    let token: String?
}
