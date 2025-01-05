import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @State private var deviceOrientation: UIDeviceOrientation = .unknown
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: deviceOrientation.isLandscape ? .leading : .bottom) {
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
                
                CustomTabBar(
                    selectedTab: $selectedTab,
                    deviceOrientation: deviceOrientation
                )
                .padding(
                    deviceOrientation.isLandscape ? .leading : .bottom,
                    deviceOrientation.isLandscape ? 20 : 0
                )
            }
        }
        .onRotate { newOrientation in
            deviceOrientation = newOrientation
            print("Device rotated to: \(newOrientation)")
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

// End of file. No additional code.
