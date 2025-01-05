//
//  User.swift
//  CycleMate
//

import Foundation

/// A model representing a user.
struct User: Identifiable, Codable, Equatable {
    /// The unique identifier for the user.
    let id: String
    
    /// The user's first name.
    let firstName: String?
    
    /// The user's last name.
    let lastName: String?
    
    /// The user's email address.
    let email: String?
    
    /// The URL of the user's profile photo.
    let photoURL: String?
    
    /// The date the user was created.
    let createdAt: Date
    
    /// The user's date of birth.
    let dateOfBirth: Date?
    
    /// The authentication provider for the user.
    let provider: String
    
    /// A flag indicating if the user's profile is completed.
    let isProfileCompleted: Bool
    
    /// A computed property that returns the user's full name.
    var fullName: String {
        return [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }
    
    /// Initializes a new instance of `User` from an `AuthUser`.
    /// - Parameter authUser: The authenticated user.
    init(from authUser: AuthUser) {
        self.id = authUser.id
        self.firstName = authUser.firstName
        self.lastName = authUser.lastName
        self.email = authUser.email
        self.photoURL = authUser.photoURL
        self.createdAt = authUser.createdAt
        self.dateOfBirth = authUser.dateOfBirth
        self.provider = authUser.provider.rawValue
        self.isProfileCompleted = authUser.isProfileCompleted
    }
    
    /// Checks if two `User` instances are equal.
    /// - Parameters:
    ///   - lhs: The left-hand side `User` instance.
    ///   - rhs: The right-hand side `User` instance.
    /// - Returns: A Boolean value indicating whether the two instances are equal.
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

// End of file. No additional code.