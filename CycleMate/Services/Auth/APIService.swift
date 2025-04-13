// ADD: signIn method
func signIn(email: String, password: String) async throws -> AuthResponse {
    let loginData: [String: Any] = [
        "email": email,
        "password": password
    ]
    
    let url = URL(string: "\(baseURL)/auth/login")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: loginData)
    
    print("📡 Sending login request...")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw AuthError.invalidResponse
    }
    
    print("📥 Received response with status: \(httpResponse.statusCode)")
    
    guard (200...299).contains(httpResponse.statusCode) else {
        throw AuthError.networkError("Server responded with status: \(httpResponse.statusCode)")
    }
    
    return try JSONDecoder().decode(AuthResponse.self, from: data)
}