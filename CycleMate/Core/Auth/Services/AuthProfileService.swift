//
//  AuthProfileService.swift
//  CycleMate
//
//  Created by Poranek on 12/04/2025.
//

import SwiftUI
import FirebaseAuth

class AuthProfileService {
    static let shared = AuthProfileService()
    private let authService = AuthenticationService()
    
    // MARK: - Profile Management
    func updateProfileImage(_ image: UIImage, for userId: String) async throws -> String {
        let profileImageManager = ProfileImageManager.shared
        return try await profileImageManager.uploadProfileImage(image, userId: userId)
    }
    
    func completeUserProfile(userId: String, firstName: String, lastName: String, dateOfBirth: Date, authToken: String?) async throws -> User {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BackendBaseURL") as? String else {
            throw AuthError.networkError("Missing base URL configuration")
        }
        
        let updateURL = "\(baseURL)/auth/profile"
        guard let url = URL(string: updateURL) else {
            throw AuthError.networkError("Invalid URL")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let updateData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "dateOfBirth": dateFormatter.string(from: dateOfBirth),
            "isProfileCompleted": true
        ]
        
        let (data, response) = try await performRequest(
            url: url,
            method: "PUT",
            body: updateData,
            token: authToken
        )
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("❌ Server error: \(errorString)")
            }
            throw AuthError.profileUpdateFailed
        }
        
        let profileData = try JSONDecoder().decode(ProfileResponse.self, from: data)
        
        return User(
            id: userId,
            firstName: profileData.firstName,
            lastName: profileData.lastName,
            email: profileData.email,
            photoURL: "",
            createdAt: Date(),
            dateOfBirth: dateOfBirth,
            provider: "email",
            isProfileCompleted: profileData.profileCompleted,
            backgroundColor: profileData.backgroundColor
        )
    }
    
    // MARK: - Private Helpers
    private func performRequest(
        url: URL,
        method: String,
        body: [String: Any],
        token: String?
    ) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        return try await URLSession.shared.data(for: request)
    }
}

// MARK: - Response Models
private struct ProfileResponse: Codable {
    let email: String
    let firstName: String
    let lastName: String
    let dateOfBirth: String
    let backgroundColor: String?
    let profileCompleted: Bool
}
