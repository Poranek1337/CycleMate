import SwiftUI

// MARK: - Tab Model
enum Tab: String, CaseIterable {
    case home, map, calendar
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .map: return "map.fill"
        case .calendar: return "calendar"
        }
    }
}

// MARK: - Custom Tab Bar View
struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @Environment(\.colorScheme) private var colorScheme
    let deviceOrientation: UIDeviceOrientation
    
    private var selectedColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var unselectedColor: Color {
        .gray.opacity(0.5)
    }
    
    private var orientationDescription: String {
        switch deviceOrientation {
        case .portrait: return "Portrait"
        case .portraitUpsideDown: return "Portrait Upside Down"
        case .landscapeLeft: return "Landscape Left"
        case .landscapeRight: return "Landscape Right"
        case .faceUp: return "Face Up"
        case .faceDown: return "Face Down"
        case .unknown: return "Unknown"
        @unknown default: return "Unknown New Case"
        }
    }
    
    private var isLandscape: Bool {
        let landscape = deviceOrientation.isLandscape
        print("\n=== Orientation Debug Info ===")
        print("Current Orientation: \(orientationDescription)")
        print("Raw Value: \(deviceOrientation.rawValue)")
        print("Is Landscape: \(landscape)")
        return landscape
    }
    
    var body: some View {
        if isLandscape {
            // Vertical layout for landscape
            VStack(spacing: 30) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(selectedTab == tab ? Color.gray.opacity(0.2) : .clear)
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: tab.icon)
                                .font(.system(size: 24))
                                .foregroundColor(selectedTab == tab ? selectedColor : unselectedColor)
                        }
                    }
                }
            }
            .frame(width: 60)
            .padding(.horizontal, 5)
            .padding(.vertical, 20)
            .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.white.opacity(0.8))
            .position(
                x: deviceOrientation == .landscapeRight ? UIScreen.main.bounds.width - 30 : 30,
                y: UIScreen.main.bounds.height / 2
            )
        } else {
            // Horizontal layout for portrait
            ZStack(alignment: .leading) {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .offset(x: selectedTabOffset)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                
                HStack(spacing: 0) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = tab
                            }
                        } label: {
                            Image(systemName: tab.icon)
                                .font(.system(size: 24))
                                .foregroundColor(selectedTab == tab ? selectedColor : unselectedColor)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .frame(height: 60)
            .padding(.vertical, 20)
            .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.white.opacity(0.8))
        }
    }
    
    private var selectedTabOffset: CGFloat {
        let tabWidth = UIScreen.main.bounds.width / CGFloat(Tab.allCases.count)
        if let index = Tab.allCases.firstIndex(of: selectedTab) {
            return tabWidth * CGFloat(index) + (tabWidth - 50) / 2
        }
        return 0
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(.home), deviceOrientation: .portrait)
}

// End of file. No additional code.
