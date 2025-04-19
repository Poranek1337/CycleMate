//
//  AuthenticationProtocol.swift
//  CycleMate
//
//  Created by Poranek on 14/04/2025.
//

import Foundation

protocol AuthenticationProtocol {
    func signIn(email: String, password: String) async throws -> AuthResponse
    func signUp(email: String, password: String) async throws -> AuthResponse
    func validateToken(_ token: String) async throws -> AuthResponse
    func createUser(registrationData: [String: Any]) async throws -> AuthResponse
    func authenticateWithGoogle(request: GoogleAuthRequest) async throws -> AuthResponse
}
