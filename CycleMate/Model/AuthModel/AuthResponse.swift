//
//  AuthResponse.swift
//  CycleMate
//
//  Created by Poranek on 14/12/2024.
//

import Foundation

/// A model representing the response from authentication endpoints
struct AuthResponse: Codable {
    /// The unique identifier of the authenticated user
    let userId: Int
    
    /// The user's email address
    let email: String
    
    /// The authentication token
    let token: String
}
