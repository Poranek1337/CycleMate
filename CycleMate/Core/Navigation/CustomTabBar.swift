import SwiftUI

// Tab Model remains the same
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
    
    // Properties remain the same
    private var selectedColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var unselectedColor: Color {
        .gray.opacity(0.5)
    }
    
    private var isLandscape: Bool {
        deviceOrientation.isLandscape
    }
    
    var body: some View {
        if isLandscape {
            // Vertical layout for landscape
            GeometryReader { geometry in
                let tabWidth: CGFloat = 52 // Width of the tab bar with padding
                let edgeDistance: CGFloat = tabWidth / 2 // Distance from edge to center of tab bar
                
                VStack(spacing: 15) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = tab
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(selectedTab == tab ? Color.gray.opacity(0.2) : .clear)
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: tab.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(selectedTab == tab ? selectedColor : unselectedColor)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Material.ultraThinMaterial)
                )
                .frame(width: tabWidth)
                // Use exact positioning from edges
                .position(
                    x: deviceOrientation == .landscapeLeft ?
                        geometry.size.width - edgeDistance : // Right edge for landscapeLeft
                        deviceOrientation == .landscapeRight ?
                            edgeDistance : // Left edge for landscapeRight
                            edgeDistance, // Default edge for other orientations
                    y: geometry.size.height / 2
                )
            }
        } else {
            // Portrait layout
            VStack {
                Spacer()
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
    }
    
    // selectedTabOffset remains the same
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
