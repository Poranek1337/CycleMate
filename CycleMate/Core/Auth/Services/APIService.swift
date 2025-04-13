//
//  APIService.swift
//  CycleMate
//
//  Created by Poranek on 12/04/2025.
//

import Foundation

class APIService {
    private let baseURL: String
    
    init() {
        self.baseURL = Bundle.main.object(forInfoDictionaryKey: "BackendBaseURL") as? String ?? ""
    }
    
    // MARK: - Authentication
    func createUser(registrationData: [String: Any]) async throws -> AuthResponse {
        return try await performRequest(
            endpoint: "/auth/register",
            method: "POST",
            body: registrationData
        )
    }
    
    func signIn(email: String, password: String) async throws -> AuthResponse {
        let loginData: [String: Any] = [
            "email": email,
            "password": password
        ]
        return try await performRequest(
            endpoint: "/auth/login",
            method: "POST",
            body: loginData
        )
    }
    
    func validateToken(_ token: String) async throws -> AuthResponse {
        return try await performRequest(
            endpoint: "/auth/validate",
            method: "POST",
            token: token
        )
    }
    
    // MARK: - Private Helpers
    private func performRequest(
        endpoint: String,
        method: String,
        body: [String: Any]? = nil,
        token: String? = nil
    ) async throws -> AuthResponse {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw AuthError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        print("📡 Sending request to: \(endpoint)")
        if let body = body {
            print("📦 Body: \(body)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        
        print("📥 Response status: \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Server error: \(errorString)")
            }
            throw AuthError.networkError("Server responded with status: \(httpResponse.statusCode)")
        }
        
        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }
}
