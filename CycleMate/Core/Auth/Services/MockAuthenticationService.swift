//
//  MockAuthenticationService.swift
//  CycleMate
//
//  Służy do testowania UI bez backendu - tylko konto test@test.com / 123456
//

import Foundation

class MockAuthenticationService: AuthenticationProtocol {
    func signIn(email: String, password: String) async throws -> AuthResponse {
        if email == "test@test.com" && password == "123456" {
            return AuthResponse(
                userId: 99999,
                email: email,
                token: "MOCK_TOKEN",
                firstName: "Test",
                lastName: "User",
                photoURL: nil,
                backgroundColor: "#90caf9",
                dateOfBirth: "1990-01-01",
                isProfileCompleted: true
            )
        }
        throw AuthError.invalidCredentials
    }

    func signUp(email: String, password: String) async throws -> AuthResponse {
        throw AuthError.notSupported
    }

    func validateToken(_ token: String) async throws -> AuthResponse {
        if token == "MOCK_TOKEN" {
            return AuthResponse(
                userId: 99999,
                email: "test@test.com",
                token: "MOCK_TOKEN",
                firstName: "Test",
                lastName: "User",
                photoURL: nil,
                backgroundColor: "#90caf9",
                dateOfBirth: "1990-01-01",
                isProfileCompleted: true
            )
        }
        throw AuthError.invalidResponse
    }

    func createUser(registrationData: [String : Any]) async throws -> AuthResponse {
        throw AuthError.notSupported
    }
}
