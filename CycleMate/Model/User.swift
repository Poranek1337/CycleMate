//
//  User.swift
//  CycleMate
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    let firstName: String?
    let lastName: String?
    let email: String?
    let photoURL: String?
    let createdAt: Date
    let dateOfBirth: Date?
    let provider: String
    let isProfileCompleted: Bool
    
    var fullName: String {
        return [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }
    
    // Add initializer for converting from AuthUser
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
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
