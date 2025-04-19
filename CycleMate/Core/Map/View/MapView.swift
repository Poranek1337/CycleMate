//
//  MapView.swift
//  CycleMate
//

import SwiftUI
import MapLibre
import CoreLocation
import UIKit

// MARK: - Main View
struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var searchViewModel = LocationSearchViewModel()

    @State private var isDrawerExpanded: Bool = false
    @State private var isDrawerHalfExpanded: Bool = false
    @FocusState private var isSearchFocused: Bool
    
    @State private var keyboardHeight: CGFloat = 0
    
    private var mapTilerKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "MapTilerAPIKey") as? String else {
            fatalError("MapTilerAPIKey not found in Info.plist")
        }
        return key
    }
    
    private var styleURL: String {
        "\(viewModel.selectedMapStyle.styleURL)?key=\(mapTilerKey)"
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MapViewRepresentable(
                    styleURL: styleURL,
                    userLocation: locationManager.userLocation,
                    userHeading: locationManager.userHeading,
                    userCourse: locationManager.userCourse,
                    isTrackingUser: viewModel.isTrackingUser,
                    cameraAltitude: viewModel.cameraAltitude,
                    onMapInteraction: {
                        viewModel.handleMapInteraction()
                    },
                    geocodingHits: viewModel.geocodingHits,
                    selectedGeocodingHit: viewModel.selectedGeocodingHit,
                    shouldCenterOnSelection: viewModel.shouldCenterOnSelection,
                    boundingBox: viewModel.boundingBox
                )
                .frame(width: geometry.size.width)
                .ignoresSafeArea()
                VStack {
                    HStack {
                        Spacer()
                        LocationSearchView(
                            searchViewModel: searchViewModel,
                            onEditingChanged: { active in
                                isSearchFocused = active
                                if active {
                                    withAnimation {
                                        isDrawerExpanded = true
                                        isDrawerHalfExpanded = true
                                    }
                                }
                            }
                        )
                        .focused($isSearchFocused)
                        Spacer()
                    }
                    Spacer().frame(height: 30)
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            Button(action: {
                                viewModel.toggleTracking()
                            }) {
                                Image(systemName: viewModel.isTrackingUser ? "location.fill" : "location")
                                    .font(.title2)
                                    .foregroundColor(viewModel.isTrackingUser ? .accentColor : .primary)
                                    .padding(12)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                            Menu {
                                ForEach(MapViewModel.MapStyle.allCases, id: \.self) { style in
                                    Button(style.styleName) {
                                        viewModel.selectedMapStyle = style
                                    }
                                }
                            } label: {
                                Image(systemName: "map")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                    .padding(12)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.trailing, 10)
                    }
                    
                    Drawer(
                        isExpanded: $isDrawerExpanded,
                        isHalfExpanded: $isDrawerHalfExpanded,
                        minHeight: 70,
                        halfHeight: geometry.size.height * 0.45,
                        fullHeight: geometry.size.height * 0.87,
                        keyboardHeight: keyboardHeight
                    ) {
                        LocationSearchCompletionsView(
                            searchResults: searchViewModel.results,
                            onSelect: { selectedHit in
                                viewModel.handleSearchSelection(selectedHit)
                                searchViewModel.selectResult(selectedHit)
                                isSearchFocused = false
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        isDrawerExpanded = false
                                        isDrawerHalfExpanded = false
                                    }
                                }
                            }
                        )
                    }
                }
            }
        }
        .onAppear {
            locationManager.startUpdatingLocation()
            if locationManager.hasLocationPermission {
                viewModel.isTrackingUser = true
            }
            searchViewModel.onResultsUpdated = { hits in
                viewModel.updateGeocodingHits(hits)
                if !hits.isEmpty {
                    withAnimation {
                        isDrawerExpanded = true
                        isDrawerHalfExpanded = true
                    }
                }
            }
            
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notification in
                let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
                keyboardHeight = keyboardFrame.height
            }
            
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                keyboardHeight = 0
            }
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }

        .onChange(of: searchViewModel.searchTextField) { _, newValue in
            if newValue.isEmpty && !isSearchFocused {
                withAnimation {
                    isDrawerExpanded = false
                    isDrawerHalfExpanded = false
                }
            }
        }
        .onChange(of: searchViewModel.selectedResult) { _, result in
            if let _ = result {
                withAnimation { isDrawerExpanded = false; isDrawerHalfExpanded = false }
            }
        }
        .onChange(of: isDrawerExpanded) { _, expanded in
            if !expanded {
                searchViewModel.searchTextField = ""
            }
        }
    }
}

// MARK: - MapView Representable
struct MapViewRepresentable: UIViewRepresentable {
    let styleURL: String
    let userLocation: CLLocationCoordinate2D?
    let userHeading: Double
    let userCourse: Double
    let isTrackingUser: Bool
    let cameraAltitude: Double
    let onMapInteraction: () -> Void
    let geocodingHits: [GeocodingHit]
    let selectedGeocodingHit: GeocodingHit?
    let shouldCenterOnSelection: Bool
    let boundingBox: (min: CLLocationCoordinate2D, max: CLLocationCoordinate2D)?
    
    func makeUIView(context: Context) -> MLNMapView {
        let mapView = MLNMapView(frame: .zero)
        mapView.styleURL = URL(string: styleURL)
        
        mapView.showsUserLocation = true
        mapView.showsUserHeadingIndicator = true
        mapView.minimumZoomLevel = 1
        mapView.maximumZoomLevel = 20
        mapView.setZoomLevel(10, animated: true)

        mapView.logoView.isHidden = true
        mapView.compassView.isHidden = true
        mapView.attributionButton.isHidden = true

        mapView.backgroundColor = .black
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        context.coordinator.mapView = mapView
        context.coordinator.onMapInteraction = onMapInteraction
        mapView.delegate = context.coordinator

        mapView.isRotateEnabled = true
        mapView.isScrollEnabled = true
        mapView.isPitchEnabled = true
        mapView.isZoomEnabled = true

        updateAnnotations(mapView)

        return mapView
    }
    
    func updateUIView(_ uiView: MLNMapView, context: Context) {
        if isTrackingUser, let location = userLocation {
            uiView.setUserTrackingMode(.followWithHeading, animated: false) {}
            let camera = MLNMapCamera(
                lookingAtCenter: location,
                altitude: cameraAltitude,
                pitch: 45,
                heading: userCourse > 0 ? userCourse : userHeading
            )
            MLNMapView.animate(withDuration: 0.15, delay: 0, options: .curveLinear) {
                uiView.setCamera(camera, animated: false)
            }
        } else if shouldCenterOnSelection, let selected = selectedGeocodingHit {
            uiView.setUserTrackingMode(.none, animated: false) {}
            let coordinate = CLLocationCoordinate2D(latitude: selected.point.lat, longitude: selected.point.lng)
            let camera = MLNMapCamera(
                lookingAtCenter: coordinate,
                altitude: 600,
                pitch: 30,
                heading: 0
            )
            MLNMapView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                uiView.setCamera(camera, animated: false)
            }
        } else if let bbox = boundingBox {
            uiView.setUserTrackingMode(.none, animated: false) {}
            
            let centerLat = (bbox.min.latitude + bbox.max.latitude) / 2
            let centerLng = (bbox.min.longitude + bbox.max.longitude) / 2
            let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng)
            
            let latDelta = abs(bbox.max.latitude - bbox.min.latitude)
            let lngDelta = abs(bbox.max.longitude - bbox.min.longitude)
            let maxDelta = max(latDelta, lngDelta)
            let altitude = maxDelta * 111000 * 1.5
            
            let camera = MLNMapCamera(
                lookingAtCenter: center,
                altitude: altitude,
                pitch: 0,
                heading: 0
            )
            
            MLNMapView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                uiView.setCamera(camera, animated: false)
            }
        }

        updateAnnotations(uiView)
    }
    
    private func updateAnnotations(_ mapView: MLNMapView) {
        mapView.removeAnnotations(mapView.annotations ?? [])
        let annotations = geocodingHits.map { hit -> MLNPointAnnotation in
            let annotation = MLNPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: hit.point.lat, longitude: hit.point.lng)
            annotation.title = hit.name
            annotation.subtitle = [hit.street, hit.housenumber, hit.city, hit.country].compactMap { $0 }.joined(separator: ", ")
            return annotation
        }
        mapView.addAnnotations(annotations)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onMapInteraction: onMapInteraction)
    }
    
    class Coordinator: NSObject, MLNMapViewDelegate {
        weak var mapView: MLNMapView?
        var onMapInteraction: () -> Void
        var isGestureInProgress: Bool = false
        var isAnimatingToUserLocation: Bool = false
        
        init(onMapInteraction: @escaping () -> Void) {
            self.onMapInteraction = onMapInteraction
            super.init()
        }
        
        func mapView(_ mapView: MLNMapView, regionWillChangeWith reason: MLNCameraChangeReason, animated: Bool) {
            if reason == .gesturePan || reason == .gesturePinch || reason == .gestureRotate || reason == .gestureTilt {
                isGestureInProgress = true
                mapView.setUserTrackingMode(.none, animated: false) {}
                onMapInteraction()
            }
        }
        
        func mapView(_ mapView: MLNMapView, regionDidChangeWith reason: MLNCameraChangeReason, animated: Bool) {
            if isGestureInProgress &&
                (reason == .gesturePan || reason == .gesturePinch || reason == .gestureRotate || reason == .gestureTilt) {
                isGestureInProgress = false
            }
        }
        
        func mapViewDidFailLoadingMap(_ mapView: MLNMapView, withError error: Error) {
            print("Map loading failed: \(error.localizedDescription)")
        }
        
        func mapViewDidFinishLoadingMap(_ mapView: MLNMapView) {
            print("Map finished loading")
            if let location = mapView.userLocation?.coordinate {
                let camera = MLNMapCamera(
                    lookingAtCenter: location,
                    altitude: 800,
                    pitch: 45,
                    heading: 0
                )
                mapView.setCamera(camera, animated: false)
            }
        }
    }
}

#Preview {
    MapView()
}
