//
//  MapViewModel.swift
//  CycleMate
//

import SwiftUI
import MapLibre

extension Notification.Name {
    static let mapInteractionOccurred = Notification.Name("mapInteractionOccurred")
}

class MapViewModel: ObservableObject {
    @Published var isTrackingUser: Bool = false
    @Published var selectedMapStyle: MapStyle = .streets
    @Published var cameraAltitude: Double = 200
    @Published var selectedGeocodingHit: GeocodingHit?
    @Published var geocodingHits: [GeocodingHit] = []
    @Published var shouldCenterOnSelection: Bool = false
    @Published var boundingBox: (min: CLLocationCoordinate2D, max: CLLocationCoordinate2D)? = nil

    private var notificationToken: NSObjectProtocol?

    init() {
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
    
    func toggleTracking() {
        isTrackingUser.toggle()
        if isTrackingUser {
            shouldCenterOnSelection = false
            boundingBox = nil
        }
    }
    
    func handleMapInteraction() {
        isTrackingUser = false
        shouldCenterOnSelection = false
        boundingBox = nil
    }
    
    func updateGeocodingHits(_ hits: [GeocodingHit]) {
        geocodingHits = hits
        calculateBoundingBox(for: hits)
    }

    func handleSearchSelection(_ hit: GeocodingHit) {
        selectedGeocodingHit = hit
        shouldCenterOnSelection = true
        boundingBox = nil
        isTrackingUser = false
    }

    private func calculateBoundingBox(for hits: [GeocodingHit]) {
        guard !hits.isEmpty else {
            boundingBox = nil
            return
        }

        var minLat = Double.infinity
        var maxLat = -Double.infinity
        var minLng = Double.infinity
        var maxLng = -Double.infinity

        for hit in hits {
            minLat = min(minLat, hit.point.lat)
            maxLat = max(maxLat, hit.point.lat)
            minLng = min(minLng, hit.point.lng)
            maxLng = max(maxLng, hit.point.lng)
        }

        let latSpan = maxLat - minLat
        let lngSpan = maxLng - minLng

        let latPadding = latSpan * 0.3
        let lngPadding = lngSpan * 0.3

        let minPadding = 0.01
        let effectiveLatPadding = max(latPadding, minPadding)
        let effectiveLngPadding = max(lngPadding, minPadding)

        boundingBox = (
            min: CLLocationCoordinate2D(
                latitude: minLat - effectiveLatPadding,
                longitude: minLng - effectiveLngPadding
            ),
            max: CLLocationCoordinate2D(
                latitude: maxLat + effectiveLatPadding,
                longitude: maxLng + effectiveLngPadding
            )
        )
    }

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
