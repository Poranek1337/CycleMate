import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Dependencies
    private let authService: APIService
    private let userStorage: UserStorage
    private let authProfileService: AuthProfileService
    private let apiService: APIService
    private let mockAuthService = MockAuthenticationService()

    // MARK: - Published Properties
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var showEmailAuth = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showUserDataForm = false
    @Published var userProfileImage: UIImage?
    @Published var userBackgroundColor: Color?
    
    // MARK: - Form Properties
    @Published var email = ""
    @Published var password = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var dateOfBirth = Date()
    @Published private var authToken: String?
    
    // MARK: - Initialization
    init(
        authService: APIService = APIService(),
        userStorage: UserStorage = UserStorage(),
        authProfileService: AuthProfileService = AuthProfileService.shared,
        apiService: APIService = APIService()
    ) {
        self.authService = authService
        self.userStorage = userStorage
        self.authProfileService = authProfileService
        self.apiService = apiService
        
        Task {
            await checkSession()
        }
    }
    
    // MARK: - Session Management
    func checkSession() async {
        print("🔍 Checking session...")
        if let savedUser = userStorage.loadUserData() {
            print("✅ Found saved user data")
            self.currentUser = savedUser
            if let token = savedUser.token {
                print("✅ Found token: \(token)")
                self.authToken = token
                userStorage.saveToken(token)
            }
            if let backgroundColor = savedUser.backgroundColor,
               let color = ColorGenerator.hexStringToColor(backgroundColor) {
                self.userBackgroundColor = color
            }
        } else {
            print("❌ No saved user data found")
        }
    }

    // MARK: - Authentication Methods
    func createVerifiedUser(email: String, password: String) async throws {
        do {
            let profileColor = ColorGenerator.generateProfileColor()
            let colorHex = ColorGenerator.colorToHexString(profileColor)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: dateOfBirth)
            
            let registrationData: [String: Any] = [
                "email": email,
                "password": password,
                "firstName": firstName,
                "lastName": lastName,
                "dateOfBirth": dateString,
                "backgroundColor": colorHex
            ]
            
            let authResponse = try await apiService.createUser(registrationData: registrationData)
            self.setupUserSession(authResponse: authResponse, colorHex: colorHex)
        } catch {
            print("❌ User creation failed: \(error)")
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        print("🔄 Starting sign in process...")
        if email == "test@test.com" && password == "123456" {
            let authResponse = try await mockAuthService.signIn(email: email, password: password)
            print("✅ Mock sign in successful, token: \(authResponse.token)")
            setupUserSession(authResponse: authResponse, colorHex: "#90caf9")
            return
        }

        try await handleSignIn(email: email, password: password)
    }
    
    // MARK: - Profile Management
    func updateProfileImage(_ image: UIImage) async {
        print("🔄 Starting profile image upload")
        do {
            guard let currentUser = currentUser,
                  let token = currentUser.token else {
                print("❌ No user or token found")
                throw AuthError.userNotFound
            }
            
            print("📤 Uploading image with token: \(token)")
            let imageUrl = try await authProfileService.updateProfileImage(image, token: token)
            print("✅ Image uploaded successfully, URL: \(imageUrl)")
            
            var updatedUser = currentUser
            updatedUser.photoURL = imageUrl
            updatedUser.isProfileCompleted = true
            
            _ = try ProfileImageManager.shared.saveImageLocally(image, withToken: token)
            
            await MainActor.run {
                self.currentUser = updatedUser
                self.userProfileImage = image
            }
            
            userStorage.saveUserData(updatedUser)
            print("✅ User data and profile image updated")
            
        } catch {
            print("❌ Failed to update profile image: \(error)")
            self.handleError(error)
        }
    }
    
    func completeUserProfile() async throws {
        guard let userId = currentUser?.id else { throw AuthError.userNotFound }
        
        let updatedUser = try await authProfileService.completeUserProfile(
            userId: userId,
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth,
            authToken: authToken
        )
        
        self.currentUser = updatedUser
        userStorage.saveUserData(updatedUser)
    }
    
    private func handleSignIn(email: String, password: String) async throws {
        print("🔄 Handling real sign in...")
        let authResponse = try await apiService.signIn(email: email, password: password)
        print("✅ Sign in successful, token: \(authResponse.token)")
        try await fetchAndSetupUserProfile(with: authResponse)
    }
    
    private func setupUserSession(authResponse: AuthResponse, colorHex: String) {
        print("🔄 Setting up user session...")
        self.authToken = authResponse.token
        userStorage.saveToken(authResponse.token)
        print("✅ Token saved: \(authResponse.token)")
        
        let user = User(
            id: String(authResponse.userId),
            firstName: firstName,
            lastName: lastName,
            email: email,
            photoURL: "",
            createdAt: Date(),
            dateOfBirth: dateOfBirth,
            provider: "email",
            isProfileCompleted: false,
            backgroundColor: colorHex,
            token: authResponse.token // Dodaj token do użytkownika
        )
        
        self.currentUser = user
        self.userBackgroundColor = ColorGenerator.hexStringToColor(colorHex)
        self.showUserDataForm = false
        userStorage.saveUserData(user)
        print("✅ User data saved")
    }
    
    // MARK: - Profile Image Management
    func uploadProfileImage(_ image: UIImage) async throws {
        print("\n🔄 Rozpoczęcie wysyłania zdjęcia profilowego")
        
        guard let token = userStorage.getToken() else {
            print("❌ Nie znaleziono tokenu autoryzacji")
            throw AuthError.userNotFound
        }
        
        print("✅ Znaleziono token: \(token)")
        
        do {
            try await validateToken(token)
            print("✅ Token zweryfikowany pomyślnie")
            
            let imageUrl = try await authProfileService.updateProfileImage(image, token: token)
            print("✅ Zdjęcie wysłane pomyślnie")
            print("📍 URL zdjęcia: \(imageUrl)")
            
            if var updatedUser = currentUser {
                updatedUser.photoURL = imageUrl
                updatedUser.isProfileCompleted = true
                updatedUser.token = token
                
                await MainActor.run {
                    self.currentUser = updatedUser
                    self.userProfileImage = image
                }
                
                userStorage.saveUserData(updatedUser)
                print("✅ Dane użytkownika zaktualizowane\n")
            } else {
                print("❌ Nie znaleziono bieżącego użytkownika")
                throw AuthError.userNotFound
            }
            
        } catch {
            print("❌ Wysyłanie nie powiodło się: \(error.localizedDescription)")
            throw error
        }
    }

    private func validateToken(_ token: String) async throws {
        print("🔄 Validating token...")
        _ = try await apiService.validateToken(token)
        print("✅ Token is valid")
    }

    // MARK: - Helper Methods
    private func resetUserSession() {
        self.currentUser = nil
        self.authToken = nil
        userStorage.removeToken()
        userStorage.removeUserData()
    }
    
    private func handleError(_ error: Error) {
        print("❌ Error: \(error)")
        self.errorMessage = error.localizedDescription
        self.showError = true
    }
    
    private func fetchAndSetupUserProfile(with authResponse: AuthResponse) async throws {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BackendBaseURL") as? String else {
            throw AuthError.networkError("Missing base URL configuration")
        }
        
        let profileUrl = URL(string: "\(baseURL)/auth/profile")!
        var profileRequest = URLRequest(url: profileUrl)
        profileRequest.httpMethod = "GET"
        profileRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        profileRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        profileRequest.setValue("Bearer \(authResponse.token)", forHTTPHeaderField: "Authorization")
        
        profileRequest.setValue(baseURL, forHTTPHeaderField: "Origin")
        profileRequest.setValue("true", forHTTPHeaderField: "Access-Control-Allow-Credentials")
        
        print("🔄 Fetching user profile data")
        print("🌐 URL: \(profileUrl)")
        print("🔐 Token: \(authResponse.token)")
        
        let (profileData, profileResponse) = try await URLSession.shared.data(for: profileRequest)
        
        guard let httpResponse = profileResponse as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorString = String(data: profileData, encoding: .utf8) {
                print("❌ Server error response: \(errorString)")
            }
            throw AuthError.networkError("Failed to fetch user data: \(httpResponse.statusCode)")
        }
        
        struct UserProfileResponse: Codable {
            let email: String
            let firstName: String
            let lastName: String
            let dateOfBirth: String
            let backgroundColor: String?
            let profileCompleted: Bool
        }
        
        let decoder = JSONDecoder()
        let userProfile = try decoder.decode(UserProfileResponse.self, from: profileData)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateOfBirth = dateFormatter.date(from: userProfile.dateOfBirth)
        
        let user = User(
            id: String(authResponse.userId),
            firstName: userProfile.firstName,
            lastName: userProfile.lastName,
            email: userProfile.email,
            photoURL: "",
            createdAt: Date(),
            dateOfBirth: dateOfBirth,
            provider: "email",
            isProfileCompleted: userProfile.profileCompleted,
            backgroundColor: userProfile.backgroundColor
        )
        
        self.currentUser = user
        self.authToken = authResponse.token
        
        if let backgroundColor = user.backgroundColor,
           let color = ColorGenerator.hexStringToColor(backgroundColor) {
            self.userBackgroundColor = color
        }
        
        userStorage.saveToken(authResponse.token)
        userStorage.saveUserData(user)
    }

    func resetErrors() {
        showError = false
        errorMessage = ""
    }
    
    func resetForm() {
        firstName = ""
        lastName = ""
        dateOfBirth = Date()
        email = ""
        password = ""
        userProfileImage = nil
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            resetUserSession()
            print("✅ Sign out successful")
        } catch {
            print("❌ Failed to sign out: \(error)")
        }
    }
}
