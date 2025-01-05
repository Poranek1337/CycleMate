import SwiftUI

struct MainTabView: View {
    // MARK: - Properties
    @State private var selectedTab: Tab = .home
    @State private var deviceOrientation: UIDeviceOrientation = .unknown
    @State private var isTabBarVisible = true
    @State private var lastInteractionTime = Date()
    
    // Haptic feedback manager
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    // Helper computed property for proper orientation handling
    private var isValidOrientation: Bool {
        switch deviceOrientation {
        case .portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: deviceOrientation.isLandscape ? .leading : .bottom) {
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
                .animation(.easeInOut, value: selectedTab)
                .ignoresSafeArea()
                .onChange(of: selectedTab) { oldValue, newValue in
                    hapticFeedback.impactOccurred()
                    updateInteractionTime()
                }
                .gesture(
                    TapGesture()
                        .onEnded { _ in
                            if deviceOrientation.isLandscape && isValidOrientation {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isTabBarVisible = true
                                }
                                updateInteractionTime()
                            }
                        }
                )
                
                // Custom TabBar with conditional rendering based on orientation
                if deviceOrientation.isLandscape && isValidOrientation {
                    CustomTabBar(
                        selectedTab: $selectedTab,
                        deviceOrientation: deviceOrientation
                    )
                    .opacity(isTabBarVisible ? 1 : 0)
                    .offset(x: isTabBarVisible ? 0 : -100)
                    .animation(.easeInOut(duration: 0.3), value: isTabBarVisible)
                } else {
                    CustomTabBar(
                        selectedTab: $selectedTab,
                        deviceOrientation: deviceOrientation
                    )
                }
            }
        }
        .onRotate { newOrientation in
            if newOrientation != deviceOrientation {
                deviceOrientation = newOrientation
                if newOrientation.isLandscape && isValidOrientation {
                    isTabBarVisible = true
                    updateInteractionTime()
                    startInactivityTimer()
                } else {
                    isTabBarVisible = true
                }
            }
        }
        .onAppear {
            // Set initial orientation
            deviceOrientation = UIDevice.current.orientation
            startInactivityTimer()
        }
    }
    
    // MARK: - Helper Functions
    private func updateInteractionTime() {
        lastInteractionTime = Date()
        if !isTabBarVisible {
            withAnimation(.easeInOut(duration: 0.3)) {
                isTabBarVisible = true
            }
        }
    }
    
    private func startInactivityTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if deviceOrientation.isLandscape && isValidOrientation {
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
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}

#Preview {
    MainTabView()
}

// End of file
