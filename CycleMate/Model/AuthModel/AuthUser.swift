//
//  AuthUser.swift
//  CycleMate
//

import SwiftUI
import Foundation

/// An enumeration representing the different authentication providers.
enum AuthProvider: String, Codable {
    case google = "google"
    case email = "email"
}

/// A model representing an authenticated user.
struct AuthUser: Codable {
    /// The unique identifier for the user.
    let id: String
    
    /// The user's first name.
    var firstName: String?
    
    /// The user's last name.
    var lastName: String?
    
    /// The user's email address.
    var email: String?
    
    /// The URL of the user's profile photo.
    var photoURL: String?
    
    /// The date the user was created.
    var createdAt: Date
    
    /// The user's date of birth.
    var dateOfBirth: Date?
    
    /// The authentication provider for the user.
    let provider: AuthProvider
    
    /// A flag indicating if the user's profile is completed.
    var isProfileCompleted: Bool
    
    /// The background color for the user's profile when no image is set
    var backgroundColor: Color?
    
    /// The authentication token for the user
    var token: String?
    
    /// A computed property that returns the user's full name.
    var fullName: String {
        return [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case email
        case photoURL
        case createdAt
        case dateOfBirth
        case provider
        case isProfileCompleted
        case backgroundColor
        case token
    }
    
    // Custom encoding for Color
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(photoURL, forKey: .photoURL)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(dateOfBirth, forKey: .dateOfBirth)
        try container.encode(provider, forKey: .provider)
        try container.encode(isProfileCompleted, forKey: .isProfileCompleted)
        try container.encode(token, forKey: .token)
        
        // Encode Color as hex string
        if let backgroundColor = backgroundColor {
            try container.encode(ColorGenerator.colorToHexString(backgroundColor), forKey: .backgroundColor)
        }
    }
    
    // Custom decoding for Color
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        dateOfBirth = try container.decodeIfPresent(Date.self, forKey: .dateOfBirth)
        provider = try container.decode(AuthProvider.self, forKey: .provider)
        isProfileCompleted = try container.decode(Bool.self, forKey: .isProfileCompleted)
        token = try container.decodeIfPresent(String.self, forKey: .token)
        
        // Decode hex string to Color
        if let hexString = try container.decodeIfPresent(String.self, forKey: .backgroundColor) {
            backgroundColor = ColorGenerator.hexStringToColor(hexString)
        }
    }
}
