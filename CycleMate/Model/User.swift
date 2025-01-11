//
//  User.swift
//  CycleMate
//

import SwiftUI
import Foundation

/// A model representing a user.
struct User: Identifiable, Codable, Equatable {
    /// The unique identifier for the user.
    let id: String
    
    /// The user's first name.
    let firstName: String
    
    /// The user's last name.
    let lastName: String
    
    /// The user's email address.
    let email: String
    
    /// The URL of the user's profile photo.
    let photoURL: String
    
    /// The date the user was created.
    let createdAt: Date
    
    /// The user's date of birth.
    let dateOfBirth: Date?
    
    /// The authentication provider for the user.
    let provider: String
    
    /// A flag indicating if the user's profile is completed.
    let isProfileCompleted: Bool
    
    /// Add background color components
    let backgroundColor: ColorComponents?
    
    /// A computed property that returns the user's full name.
    var fullName: String {
        return [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }
    
    /// A computed property that returns the user's initials.
    var initials: String {
        ColorGenerator.generateInitials(firstName: firstName, lastName: lastName)
    }
    
    /// Custom decoder initialization
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.email = try container.decode(String.self, forKey: .email)
        self.photoURL = try container.decode(String.self, forKey: .photoURL)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.dateOfBirth = try container.decodeIfPresent(Date.self, forKey: .dateOfBirth)
        self.provider = try container.decode(String.self, forKey: .provider)
        self.isProfileCompleted = try container.decode(Bool.self, forKey: .isProfileCompleted)
        self.backgroundColor = try container.decodeIfPresent(ColorComponents.self, forKey: .backgroundColor)
    }
    
    /// Manual initialization
    init(id: String,
         firstName: String,
         lastName: String,
         email: String,
         photoURL: String,
         createdAt: Date,
         dateOfBirth: Date?,
         provider: String,
         isProfileCompleted: Bool,
         backgroundColor: ColorComponents? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.photoURL = photoURL
        self.createdAt = createdAt
        self.dateOfBirth = dateOfBirth
        self.provider = provider
        self.isProfileCompleted = isProfileCompleted
        self.backgroundColor = backgroundColor
    }
    
    /// Initializes a new instance of `User` from an `AuthUser`.
    /// - Parameter authUser: The authenticated user.
    init(from authUser: AuthUser) {
        self.id = authUser.id
        self.firstName = authUser.firstName ?? ""
        self.lastName = authUser.lastName ?? ""
        self.email = authUser.email ?? ""
        self.photoURL = authUser.photoURL ?? ""
        self.createdAt = authUser.createdAt
        self.dateOfBirth = authUser.dateOfBirth
        self.provider = authUser.provider.rawValue
        self.isProfileCompleted = authUser.isProfileCompleted
        self.backgroundColor = nil
    }
    
    /// Coding keys for Codable conformance
    private enum CodingKeys: String, CodingKey {
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
    }
    
    /// Checks if two `User` instances are equal.
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    /// Color components struct
    struct ColorComponents: Codable {
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        
        var color: Color {
            Color(.displayP3, red: red, green: green, blue: blue)
        }
    }
}
