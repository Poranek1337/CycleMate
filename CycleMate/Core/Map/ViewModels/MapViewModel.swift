//
//  MapViewModel.swift
//  CycleMate
//

import SwiftUI
import MapLibre

// Notification name remains the same
extension Notification.Name {
    static let mapInteractionOccurred = Notification.Name("mapInteractionOccurred")
}

class MapViewModel: ObservableObject {
    // Properties
    @Published var isTrackingUser: Bool = false
    @Published var selectedMapStyle: MapStyle = .streets
    @Published var cameraAltitude: Double = 200
    
    private var notificationToken: NSObjectProtocol?
    
    init() {
        // Setup notification observer
        notificationToken = NotificationCenter.default.addObserver(
            forName: .mapInteractionOccurred,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isTrackingUser = false
        }
    }
    
    deinit {
        if let token = notificationToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    // Toggle tracking function remains the same
    func toggleTracking() {
        isTrackingUser.toggle()
    }
    
    func handleMapInteraction() {
        isTrackingUser = false
    }
    
    // Map style enum remains the same
    enum MapStyle: String, CaseIterable {
        case streets = "streets"
        case outdoors = "outdoor"
        case satellite = "satellite"
        case dark = "dark"
        
        var styleName: String {
            switch self {
            case .streets: return "Streets"
            case .outdoors: return "Outdoors"
            case .satellite: return "Satellite"
            case .dark: return "Dark"
            }
        }
        
        var styleURL: String {
            "https://api.maptiler.com/maps/\(self.rawValue)/style.json"
        }
    }
}
