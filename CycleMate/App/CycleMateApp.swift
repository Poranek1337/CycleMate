//
//  CycleMateApp.swift
//  CycleMate
//

// Import required frameworks
import SwiftUI
import FirebaseCore
import Firebase
import FirebaseAuth

// AppDelegate for Firebase configuration
class AppDelegate: NSObject, UIApplicationDelegate {
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
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Initialize authentication view model
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(authViewModel)
        }
    }
}

// End of file. No additional code.
