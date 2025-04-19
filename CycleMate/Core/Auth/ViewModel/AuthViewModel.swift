import SwiftUI
import GoogleSignIn
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine

// Existing code ...

@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Dependencies
    private let authService: APIService
    private let googleAuthService: GoogleAuthService
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
        googleAuthService: GoogleAuthService = GoogleAuthService.shared,
        userStorage: UserStorage = UserStorage(),
        authProfileService: AuthProfileService = AuthProfileService.shared,
        apiService: APIService = APIService()
    ) {
        self.authService = authService
        self.googleAuthService = googleAuthService
        self.userStorage = userStorage
        self.authProfileService = authProfileService
        self.apiService = apiService
        
        Task {
            await checkSession()
        }
    }
    
    // MARK: - Session Management
    func checkSession() async {
        if let savedUser = userStorage.loadUserData() {
            self.currentUser = savedUser
            if let backgroundColor = savedUser.backgroundColor,
               let color = ColorGenerator.hexStringToColor(backgroundColor) {
                self.userBackgroundColor = color
            }
        }

        guard let token = userStorage.getToken() else {
            self.resetUserSession()
            return
        }

        if token == "MOCK_TOKEN" {
            self.authToken = token
            return
        }

        do {
            let authResponse = try await authService.validateToken(token)
            self.authToken = authResponse.token
            userStorage.saveToken(authResponse.token)

            if let user = self.currentUser {
                userStorage.saveUserData(user)
            }
        } catch {
            print("❌ Session validation failed: \(error)")
            self.resetUserSession()
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
        if email == "test@test.com" && password == "123456" {
            let authResponse = try await mockAuthService.signIn(email: email, password: password)
            let mockUser = User(
                id: String(authResponse.userId),
                firstName: "Test",
                lastName: "User",
                email: email,
                photoURL: "",
                createdAt: Date(),
                dateOfBirth: nil,
                provider: "email",
                isProfileCompleted: true,
                backgroundColor: "#90caf9",
                token: authResponse.token
            )
            self.currentUser = mockUser
            self.userBackgroundColor = ColorGenerator.hexStringToColor(mockUser.backgroundColor ?? "#90caf9")
            userStorage.saveToken(authResponse.token)
            userStorage.saveUserData(mockUser)
            return
        }

        try await handleSignIn(email: email, password: password)
    }
    
    // MARK: - Google Sign In
    @MainActor
    func signInWithGoogle() async throws {
        do {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                throw AuthError.presentationError
            }
            
            let user = try await googleAuthService.signIn(presenting: rootViewController)
            self.currentUser = user
            self.userBackgroundColor = ColorGenerator.hexStringToColor(user.backgroundColor ?? "")
            
            userStorage.saveToken(user.token ?? "")
            userStorage.saveUserData(user)
            
            if let imageUrl = URL(string: user.photoURL),
               let imageData = try? Data(contentsOf: imageUrl),
               let profileImage = UIImage(data: imageData) {
                self.userProfileImage = profileImage
            }
        } catch {
            handleError(error)
        }
    }

    // MARK: - Profile Management
    func updateProfileImage(_ image: UIImage) async {
        do {
            guard let currentUser = currentUser,
                  let token = currentUser.token else {
                throw AuthError.userNotFound
            }
            
            let imageUrl = try await authProfileService.updateProfileImage(image, token: token)
            
            var updatedUser = currentUser
            updatedUser.photoURL = imageUrl
            
            self.currentUser = updatedUser
            self.userProfileImage = image
            userStorage.saveUserData(updatedUser)
        } catch {
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
    
    // MARK: - Helper Methods
    private func resetUserSession() {
        self.currentUser = nil
        self.authToken = nil
        userStorage.removeToken()
        userStorage.removeUserData()
    }
    
    private func setupUserSession(authResponse: AuthResponse, colorHex: String) {
        self.authToken = authResponse.token
        userStorage.saveToken(authResponse.token)
        
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
            backgroundColor: colorHex
        )
        
        self.currentUser = user
        self.userBackgroundColor = ColorGenerator.hexStringToColor(colorHex)
        self.showUserDataForm = false
        userStorage.saveUserData(user)
    }
    
    private func handleError(_ error: Error) {
        print("❌ Error: \(error)")
        self.errorMessage = error.localizedDescription
        self.showError = true
    }
    
    private func handleSignIn(email: String, password: String) async throws {
        let authResponse = try await apiService.signIn(email: email, password: password)
        try await fetchAndSetupUserProfile(with: authResponse)
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

// Existing code ...
