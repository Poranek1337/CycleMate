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

class GoogleAuthService {
    static let shared = GoogleAuthService()
    
    // MARK: - Google Sign In
    func signIn(presenting viewController: UIViewController) async throws -> User {
        let result = try await performGoogleSignIn(presenting: viewController)
        let authResult = try await authenticateWithFirebase(using: result)
        return createUser(from: result, authResult: authResult)
    }
    
    // MARK: - Private Helpers
    private func performGoogleSignIn(presenting viewController: UIViewController) async throws -> GIDSignInResult {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.configurationError
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        return try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
    }
    
    private func authenticateWithFirebase(using result: GIDSignInResult) async throws -> AuthDataResult {
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.invalidCredential
        }
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        
        return try await Auth.auth().signIn(with: credential)
    }
    
    private func createUser(from result: GIDSignInResult, authResult: AuthDataResult) -> User {
        let profileColor = ColorGenerator.generateProfileColor()
        let colorHex = ColorGenerator.colorToHexString(profileColor)
        
        return User(
            id: authResult.user.uid,
            firstName: result.user.profile?.givenName ?? "",
            lastName: result.user.profile?.familyName ?? "",
            email: result.user.profile?.email ?? "",
            photoURL: result.user.profile?.imageURL(withDimension: 200)?.absoluteString ?? "",
            createdAt: Date(),
            dateOfBirth: Date(),
            provider: "google",
            isProfileCompleted: false,
            backgroundColor: colorHex
        )
    }
}
