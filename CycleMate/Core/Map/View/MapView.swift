//
//  MapView.swift
//  CycleMate
//

// Required imports
import SwiftUI
import MapLibre
import CoreLocation
import UIKit

// MARK: - Main View
struct MapView: View {
    // Properties
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = MapViewModel()
    
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
                    frame: geometry.frame(in: .global),
                    onMapInteraction: {
                        viewModel.handleMapInteraction()
                    }
                )
                .frame(width: geometry.size.width + 20, height: geometry.size.height + 20)
                .offset(x: -10, y: -10)
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer().frame(height: 60)
                    
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
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            locationManager.startUpdatingLocation()
            if locationManager.hasLocationPermission {
                viewModel.isTrackingUser = true
            }
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
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
    let frame: CGRect
    let onMapInteraction: () -> Void
    
    func makeUIView(context: Context) -> MLNMapView {
        let mapView = MLNMapView(frame: frame)
        mapView.styleURL = URL(string: styleURL)
        
        mapView.showsUserLocation = true
        mapView.showsUserHeadingIndicator = true
        mapView.minimumZoomLevel = 16
        mapView.maximumZoomLevel = 20
        
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
        
        return mapView
    }
    
    func updateUIView(_ uiView: MLNMapView, context: Context) {
        uiView.styleURL = URL(string: styleURL)
        
        if let location = userLocation {
            let heading = userCourse > 0 ? userCourse : userHeading
            
            if isTrackingUser {
                if !context.coordinator.isAnimatingToUserLocation {
                    context.coordinator.isAnimatingToUserLocation = true
                    
                    UIView.animate(withDuration: 0.5) {
                        uiView.setUserTrackingMode(.followWithHeading, animated: true)
                        
                        let camera = MLNMapCamera(
                            lookingAtCenter: location,
                            altitude: cameraAltitude,
                            pitch: 45,
                            heading: heading
                        )
                        uiView.setCamera(camera, animated: true)
                    } completion: { _ in
                        context.coordinator.isAnimatingToUserLocation = false
                    }
                }
            } else {
                uiView.setUserTrackingMode(.none, animated: true)
            }
        }
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
                mapView.setUserTrackingMode(.none, animated: false)
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
    }
}

#Preview {
    MapView()
}
