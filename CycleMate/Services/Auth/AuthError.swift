//
//  AuthError.swift
//  CycleMate
//
//  Created by Poranek on 14/12/2024.
//

import Foundation

enum AuthError: Error {
    case signInFailed
    case signUpFailed
    case signOutFailed
    case userNotFound
    case profileUpdateFailed
    case invalidEmail
    case invalidPassword
    case imageProcessingFailed
    case imageUploadFailed
    
    var description: String {
        switch self {
        case .signInFailed: return "Failed to sign in. Please try again."
        case .signUpFailed: return "Failed to create account. Please try again."
        case .signOutFailed: return "Failed to sign out. Please try again."
        case .userNotFound: return "User not found."
        case .profileUpdateFailed: return "Failed to update profile. Please try again."
        case .invalidEmail: return "Please enter a valid email address."
        case .invalidPassword: return "Password must be at least 6 characters long."
        case .imageProcessingFailed: return "Failed to process image. Please try again."
        case .imageUploadFailed: return "Failed to upload image. Please try again."
        }
    }
}

// End of file. No additional code.

