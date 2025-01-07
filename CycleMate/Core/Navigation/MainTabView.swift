//
//  MainTabView.swift
//  CycleMate
//  dev.Poranek
//

import SwiftUI

/// A view that manages the main tab navigation and handles device orientation changes.
struct MainTabView: View {
    // MARK: - Properties
    @State private var selectedTab: Tab = .home
    @State private var deviceOrientation: UIDeviceOrientation = .unknown
    @State private var isTabBarVisible = true
    @State private var lastInteractionTime = Date()
    @State private var isDragging = false
    @State private var isSwipeEnabled = true
    
    /// Haptic feedback manager
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    /// Helper computed property for valid orientation
    private var effectiveOrientation: UIDeviceOrientation {
        switch deviceOrientation {
        case .portrait, .landscapeLeft, .landscapeRight:
            return deviceOrientation
        case .portraitUpsideDown:
            return .portrait
        case .faceUp, .faceDown:
            return deviceOrientation == .unknown ? .portrait : deviceOrientation
        default:
            return .portrait
        }
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: effectiveOrientation.isLandscape ? .leading : .bottom) {
                // Main TabView with pages
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(Tab.home)
                        .ignoresSafeArea()
                    
                    MapView()
                        .tag(Tab.map)
                        .ignoresSafeArea()
                    
                    CalendarView()
                        .tag(Tab.calendar)
                        .ignoresSafeArea()
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                // Remove animation from TabView to prevent unwanted transitions
                .animation(nil, value: selectedTab)
                .ignoresSafeArea()
                .onChange(of: selectedTab) { oldValue, newValue in
                    if !isDragging {
                        hapticFeedback.impactOccurred()
                        updateInteractionTime()
                        print("Changed to view: \(newValue)")
                    }
                }
                // Add gesture only in portrait mode
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { _ in
                            isDragging = true
                            updateInteractionTime()
                        }
                        .onEnded { _ in
                            isDragging = false
                        },
                    including: effectiveOrientation.isLandscape ? .subviews : .all
                )
                
                // Custom TabBar with conditional rendering based on orientation
                if effectiveOrientation.isLandscape {
                    CustomTabBar(
                        selectedTab: $selectedTab,
                        isDragging: $isDragging,
                        deviceOrientation: effectiveOrientation
                    )
                    .opacity(isTabBarVisible ? 1 : 0)
                    .offset(x: isTabBarVisible ? 0 : effectiveOrientation == .landscapeRight ? -100 : 100)
                    .animation(.easeInOut(duration: 0.3), value: isTabBarVisible)
                    .allowsHitTesting(isTabBarVisible)
                } else {
                    CustomTabBar(
                        selectedTab: $selectedTab,
                        isDragging: $isDragging,
                        deviceOrientation: effectiveOrientation
                    )
                }
            }
            // Add background tap gesture
            .contentShape(Rectangle())
            .onTapGesture {
                if effectiveOrientation.isLandscape {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isTabBarVisible = true
                    }
                    updateInteractionTime()
                }
            }
        }
        .onRotate { newOrientation in
            let isFlatOrientation = (newOrientation == .faceUp || newOrientation == .faceDown)
            if !isFlatOrientation && newOrientation != .portraitUpsideDown && newOrientation != deviceOrientation {
                deviceOrientation = newOrientation
                if newOrientation.isLandscape {
                    isTabBarVisible = true
                    updateInteractionTime()
                    startInactivityTimer()
                } else {
                    isTabBarVisible = true
                }
            }
        }
        .onAppear {
            // Set initial orientation and start timer
            let currentOrientation = UIDevice.current.orientation
            if ![.portraitUpsideDown, .faceUp, .faceDown, .unknown].contains(currentOrientation) {
                deviceOrientation = currentOrientation
            } else {
                deviceOrientation = .portrait
            }
            startInactivityTimer()
            print("Initial view: \(selectedTab)")
        }
    }
    
    // MARK: - Helper Functions
    
    /// Updates the last interaction time and shows the tab bar if hidden.
    private func updateInteractionTime() {
        lastInteractionTime = Date()
        if !isTabBarVisible {
            withAnimation(.easeInOut(duration: 0.3)) {
                isTabBarVisible = true
            }
        }
    }
    
    /// Starts a timer to hide the tab bar after a period of inactivity.
    private func startInactivityTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if effectiveOrientation.isLandscape {
                let timeSinceLastInteraction = Date().timeIntervalSince(lastInteractionTime)
                if timeSinceLastInteraction >= 3.0 && isTabBarVisible {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isTabBarVisible = false
                    }
                }
            }
        }
    }
}

// MARK: - Device Rotation View Modifier

/// A view modifier that detects device rotation and performs an action.
struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// MARK: - View Extension

extension View {
    /// Adds a modifier to perform an action when the device rotates.
    /// - Parameter action: The action to perform on rotation.
    /// - Returns: A view that performs the action on rotation.
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

// Preview
#Preview {
    MainTabView()
}
