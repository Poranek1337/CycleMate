//
//  APIService.swift
//  CycleMate
//
//  Created by Poranek on 12/04/2025.
//

import Foundation

class APIService: AuthenticationProtocol {
    private let baseURL: String
    
    init() {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "BackendBaseURL") as? String else {
            fatalError("BackendBaseURL not found in Info.plist")
        }
        self.baseURL = url
    }
    
    // MARK: - Request Methods
    func signIn(email: String, password: String) async throws -> AuthResponse {
        return try await performRequest(
            endpoint: "/api/auth/login",
            method: "POST",
            body: ["email": email, "password": password]
        )
    }
    
    func signUp(email: String, password: String) async throws -> AuthResponse {
        return try await performRequest(
            endpoint: "/api/auth/register",
            method: "POST",
            body: ["email": email, "password": password]
        )
    }
    
    func validateToken(_ token: String) async throws -> AuthResponse {
        return try await performRequest(
            endpoint: "/api/auth/validate",
            method: "GET",
            token: token,
            headers: [
                "Accept": "application/json",
                "Content-Type": "application/json"
            ]
        )
    }
    
    func createUser(registrationData: [String: Any]) async throws -> AuthResponse {
        return try await performRequest(
            endpoint: "/api/auth/register",
            method: "POST",
            body: registrationData
        )
    }
    
    // MARK: - Private Helpers
    private func performRequest(
        endpoint: String,
        method: String,
        body: [String: Any]? = nil,
        token: String? = nil,
        headers: [String: String]? = nil
    ) async throws -> AuthResponse {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw AuthError.networkError("Invalid URL: \(baseURL)\(endpoint)")
        }
        
        print("🌐 Making request to: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Dodaj domyślne nagłówki
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Dodaj dodatkowe nagłówki
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            print("📦 Request body: \(body)")
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
        
        let decoder = JSONDecoder()
        return try decoder.decode(AuthResponse.self, from: data)
    }
}
