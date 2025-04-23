import Foundation

struct AuthResponse: Codable {
    let userId: Int
    let email: String
    let token: String
    let firstName: String?
    let lastName: String?
    let photoURL: String?
    let backgroundColor: String?
    let dateOfBirth: String?
    let isProfileCompleted: Bool?
    
    enum CodingKeys: String, CodingKey {
        case userId
        case email
        case token
        case firstName
        case lastName
        case photoURL
        case backgroundColor
        case dateOfBirth
        case isProfileCompleted = "profileCompleted"
    }
}

// Dodatkowe modele do komunikacji z backendem
struct GoogleAuthRequest: Codable {
    let token: String
    let email: String
}

struct GoogleUserInfo: Codable {
    let email: String
    let givenName: String
    let familyName: String
    let picture: String?
}
