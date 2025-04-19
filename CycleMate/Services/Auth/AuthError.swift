//
//  AuthError.swift
//  CycleMate
//
//  Created by Poranek on 14/12/2024.
//

import Foundation

/// An enumeration representing authentication errors.
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
    case emailVerificationFailed
    case emailVerificationTimeout
    case networkError(String)
    case invalidResponse
    case decodingError
    case configurationError
    case presentationError
    case invalidCredential
    case unauthorizedError
    case invalidCredentials
    case notSupported

    /// A description of the error.
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
        case .emailVerificationFailed: return "Failed to verify email. Please try again."
        case .emailVerificationTimeout: return "Email verification timed out. Please try again."
        case .networkError(let message): return "Network error: \(message)"
        case .invalidResponse: return "Invalid response from server"
        case .decodingError: return "Error decoding server response"
        case .configurationError: return "Configuration error occurred"
        case .presentationError: return "Error presenting authentication view"
        case .invalidCredential: return "Invalid credentials provided"
        case .unauthorizedError: return "Unauthorized access. Please log in again."
        case .invalidCredentials: return "Invalid credentials for mock login."
        case .notSupported: return "Operation not supported in this mode."
        }
    }
}
