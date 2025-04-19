//
//  MockAuthenticationService.swift
//  CycleMate
//
//  Służy do testowania UI bez backendu - tylko konto test@test.com / 123456
//

import Foundation

// Tylko do testów - nie wrzucać na produkcję!
class MockAuthenticationService: AuthenticationProtocol {
    func signIn(email: String, password: String) async throws -> AuthResponse {
        if email == "test@test.com" && password == "123456" {
            return AuthResponse(
                userId: 99999,
                email: email,
                token: "MOCK_TOKEN",
                // Dodaj inne wymagane pola jeśli są
                // np. firstName, lastName itp.
                // W zależności od implementacji AuthResponse
                // Na razie minimalnie jak potrzeba, żeby zadziałało.
                )
        }
        throw AuthError.invalidCredentials
    }

    func signUp(email: String, password: String) async throws -> AuthResponse {
        throw AuthError.notSupported // Nie implementujemy rejestracji w mocku
    }

    func validateToken(_ token: String) async throws -> AuthResponse {
        if token == "MOCK_TOKEN" {
            return AuthResponse(
                userId: 99999,
                email: "test@test.com",
                token: "MOCK_TOKEN"
                // inne pola jeśli wymagane
            )
        }
        throw AuthError.invalidResponse
    }

    func createUser(registrationData: [String : Any]) async throws -> AuthResponse {
        throw AuthError.notSupported
    }

    func authenticateWithGoogle(request: GoogleAuthRequest) async throws -> AuthResponse {
        throw AuthError.notSupported
    }
}
