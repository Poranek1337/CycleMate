//
//  AuthenticationService.swift
//  CycleMate
//
//  Created by Poranek on 12/04/2025.
//

import Foundation
import Combine

class AuthenticationService {
    private struct UserDefaultsKeys {
        static let suiteName = "com.cyclemate.userdefaults"
        static let authToken = "com.cyclemate.auth.token"
        static let userData = "com.cyclemate.user.data"
    }
    
    private var userDefaults: UserDefaults {
        if let defaults = UserDefaults(suiteName: UserDefaultsKeys.suiteName) {
            return defaults
        }
        return UserDefaults.standard
    }
    
    // Token Management
    func saveToken(_ token: String) {
        print("🔄 Saving token to UserDefaults...")
        if UserDefaults(suiteName: UserDefaultsKeys.suiteName) == nil {
            UserDefaults.standard.addSuite(named: UserDefaultsKeys.suiteName)
        }
        
        userDefaults.set(token, forKey: UserDefaultsKeys.authToken)
        userDefaults.synchronize()
        
        if let savedToken = userDefaults.string(forKey: UserDefaultsKeys.authToken) {
            print("✅ Token successfully saved and verified: \(savedToken)")
        } else {
            print("❌ Failed to verify saved token")
        }
    }
    
    func getToken() -> String? {
        let token = userDefaults.string(forKey: UserDefaultsKeys.authToken)
        print("🔍 Retrieving token: \(token ?? "not found")")
        return token
    }
    
    func removeToken() {
        print("🗑 Removing token from UserDefaults")
        userDefaults.removeObject(forKey: UserDefaultsKeys.authToken)
        userDefaults.synchronize()
    }
    
    // User Data Management
    func saveUserData(_ user: User) {
        print("🔄 Saving user data to UserDefaults...")
        do {
            let encoder = JSONEncoder()
            let userData = try encoder.encode(user)
            userDefaults.set(userData, forKey: UserDefaultsKeys.userData)
            userDefaults.synchronize()
            print("✅ User data saved successfully")
        } catch {
            print("❌ Failed to save user data: \(error)")
        }
    }
    
    func loadUserData() -> User? {
        print("🔄 Loading user data from UserDefaults...")
        guard let userData = userDefaults.data(forKey: UserDefaultsKeys.userData) else {
            print("❌ No user data found in UserDefaults")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let user = try decoder.decode(User.self, from: userData)
            print("✅ User data loaded successfully")
            return user
        } catch {
            print("❌ Failed to load user data: \(error)")
            return nil
        }
    }
    
    func removeUserData() {
        print("🗑 Removing user data from UserDefaults")
        userDefaults.removeObject(forKey: UserDefaultsKeys.userData)
        userDefaults.synchronize()
    }
}
