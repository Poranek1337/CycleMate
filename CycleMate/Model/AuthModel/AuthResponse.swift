import Foundation

struct AuthResponse: Codable {
    let userId: Int
    let email: String
    let token: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "userId"
        case email
        case token
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
