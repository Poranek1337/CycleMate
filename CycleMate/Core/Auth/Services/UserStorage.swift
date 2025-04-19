//
//  UserStorage.swift
//  CycleMate
//
//  Created by Poranek on 14/04/2025.
//

import Foundation

class UserStorage: UserStorageProtocol {
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
    
    func saveToken(_ token: String) {
        userDefaults.set(token, forKey: UserDefaultsKeys.authToken)
        userDefaults.synchronize()
    }
    
    func getToken() -> String? {
        return userDefaults.string(forKey: UserDefaultsKeys.authToken)
    }
    
    func removeToken() {
        userDefaults.removeObject(forKey: UserDefaultsKeys.authToken)
        userDefaults.synchronize()
    }
    
    func saveUserData(_ user: User) {
        do {
            let encoder = JSONEncoder()
            let userData = try encoder.encode(user)
            userDefaults.set(userData, forKey: UserDefaultsKeys.userData)
            userDefaults.synchronize()
        } catch {
            print("❌ Failed to save user data: \(error)")
        }
    }
    
    func loadUserData() -> User? {
        guard let userData = userDefaults.data(forKey: UserDefaultsKeys.userData) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(User.self, from: userData)
        } catch {
            print("❌ Failed to load user data: \(error)")
            return nil
        }
    }
    
    func removeUserData() {
        userDefaults.removeObject(forKey: UserDefaultsKeys.userData)
        userDefaults.synchronize()
    }
}
