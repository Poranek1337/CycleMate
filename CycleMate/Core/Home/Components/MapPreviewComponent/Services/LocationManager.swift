import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var isAuthorized = false
    @Published var isLocationEnabled = false
    
    override init() {
        super.init()
        manager.delegate = self
        checkAuthorizationStatus()
        isLocationEnabled = CLLocationManager.locationServicesEnabled()
    }
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    private func checkAuthorizationStatus() {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
        default:
            isAuthorized = false
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus()
        isLocationEnabled = CLLocationManager.locationServicesEnabled()
    }
}
