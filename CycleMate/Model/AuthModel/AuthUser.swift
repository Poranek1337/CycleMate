//
//  AuthUser.swift
//  CycleMate
//

import Foundation

/// An enumeration representing the different authentication providers.
enum AuthProvider: String {
    case google = "google"
    case email = "email"
}

/// A model representing an authenticated user.
struct AuthUser {
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
    
    /// A computed property that returns the user's full name.
    var fullName: String {
        return [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }
}

// End of file. No additional code.