//
//  LocationManager.swift
//  CycleMate
//

import CoreLocation
import MapLibre

class LocationManager: NSObject, ObservableObject {
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var lastUpdateTime: Date = Date()
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var userHeading: Double = 0
    @Published var userCourse: Double = 0
    @Published var hasLocationPermission: Bool = false
    
    // MARK: - Initialization
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 0.5
        locationManager.headingFilter = 0.5
        locationManager.activityType = .fitness
        
        checkLocationAuthorization()
    }
    
    // MARK: - Private Methods
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            hasLocationPermission = true
            startUpdatingLocation()
        case .notDetermined:
            hasLocationPermission = false
            requestLocationPermission()
        case .restricted, .denied:
            hasLocationPermission = false
        @unknown default:
            hasLocationPermission = false
        }
    }
    
    // MARK: - Public Methods
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let currentTime = Date()
        let timeDiff = currentTime.timeIntervalSince(lastUpdateTime)
        
        if timeDiff >= 0.1 {
            // Smooth location updates
            if let lastLoc = lastLocation {
                let interpolationFactor: Double = 0.3
                let lat = lastLoc.coordinate.latitude + (location.coordinate.latitude - lastLoc.coordinate.latitude) * interpolationFactor
                let lon = lastLoc.coordinate.longitude + (location.coordinate.longitude - lastLoc.coordinate.longitude) * interpolationFactor
                userLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            } else {
                userLocation = location.coordinate
            }
            
            lastUpdateTime = currentTime
            lastLocation = location
            
            if location.speed > 0.5 {
                // Smooth course updates
                let newCourse = location.course
                userCourse = userCourse + (newCourse - userCourse) * 0.3
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let oldHeading = userHeading
        var newTrueHeading = newHeading.trueHeading
        
        // Handle 360-degree transition
        if abs(newTrueHeading - oldHeading) > 180 {
            if newTrueHeading > oldHeading {
                newTrueHeading -= 360
            } else {
                newTrueHeading += 360
            }
        }
        
        // Smooth heading updates
        userHeading = oldHeading + (newTrueHeading - oldHeading) * 0.3
        
        // Normalize to 0-360 range
        if userHeading < 0 {
            userHeading += 360
        } else if userHeading >= 360 {
            userHeading -= 360
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                hasLocationPermission = false
            default:
                break
            }
        }
    }
}
