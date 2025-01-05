//
//  AuthUser.swift
//  CycleMate
//

import Foundation

enum AuthProvider: String {
    case google = "google"
    case email = "email"
}

// Made the properties variables instead of constants
struct AuthUser {
    let id: String
    var firstName: String?
    var lastName: String?
    var email: String?
    var photoURL: String?
    var createdAt: Date
    var dateOfBirth: Date?
    let provider: AuthProvider
    var isProfileCompleted: Bool
    
    var fullName: String {
        return [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }
}

// End of file. No additional code.
