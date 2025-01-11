//
//  CycleMateApp.swift
//  CycleMate
//  dev.Poranek
//

import SwiftUI
import FirebaseCore
import Firebase
import FirebaseAuth

/// AppDelegate for Firebase configuration
class AppDelegate: NSObject, UIApplicationDelegate {
    /// Configures Firebase and handles first launch logic.
    /// - Parameters:
    ///   - application: The singleton app object.
    ///   - launchOptions: A dictionary indicating the reason the app was launched (if any).
    /// - Returns: A boolean indicating whether the app successfully handled the launch request.
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("🚀 Application launching")
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Check if this is first launch after install
        if !UserDefaults.standard.bool(forKey: "hasLaunched") {
            print("📱 First launch after install - clearing data")
            UserDefaults.standard.set(true, forKey: "hasLaunched")
            
            // Clear any existing auth state
            try? Auth.auth().signOut()
            
            // Clear all UserDefaults except hasLaunched
            if let bundleID = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleID)
                UserDefaults.standard.set(true, forKey: "hasLaunched")
            }
        }
        
        // Configure Firestore settings
        let settings = Firestore.firestore().settings
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        Firestore.firestore().settings = settings
        
        print("✅ Firebase configured")
        return true
    }
}

@main
struct CycleMateApp: App {
    /// Registers the app delegate for Firebase setup.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    /// Initializes the authentication view model.
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(authViewModel)
        }
    }
}
