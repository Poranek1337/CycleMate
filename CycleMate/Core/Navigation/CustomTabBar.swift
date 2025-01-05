//
//  CustomTabBar.swift
//  CycleMate
//  dev.Poranek
//

import SwiftUI

// MARK: - Tab Model

/// An enumeration representing the different tabs in the app.
enum Tab: String, CaseIterable {
    case home, map, calendar
    
    /// The icon associated with each tab.
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .map: return "map.fill"
        case .calendar: return "calendar"
        }
    }
}

// MARK: - Custom Tab Bar View

/// A custom tab bar view that supports both portrait and landscape orientations.
struct CustomTabBar: View {
    /// The currently selected tab.
    @Binding var selectedTab: Tab
    
    /// A flag indicating if the tab bar is being dragged.
    @Binding var isDragging: Bool
    
    /// The current color scheme (light or dark mode).
    @Environment(\.colorScheme) private var colorScheme
    
    /// The current device orientation.
    let deviceOrientation: UIDeviceOrientation
    
    // Properties for styling
    
    /// The color for the selected tab.
    private var selectedColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    /// The color for unselected tabs.
    private var unselectedColor: Color {
        .gray.opacity(0.5)
    }
    
    /// A flag indicating if the device is in landscape orientation.
    private var isLandscape: Bool {
        deviceOrientation.isLandscape
    }
    
    var body: some View {
        if isLandscape {
            // Vertical layout for landscape
            GeometryReader { geometry in
                let tabWidth: CGFloat = 52
                let edgeDistance: CGFloat = tabWidth / 2
                
                VStack(spacing: 15) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Button {
                            if !isDragging {
                                selectedTab = tab
                                print("Selected tab: \(tab)")
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
                        .buttonStyle(BorderlessButtonStyle())
                        .contentShape(Rectangle())
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Material.ultraThinMaterial)
                )
                .frame(width: tabWidth)
                .position(
                    x: deviceOrientation == .landscapeLeft ?
                        geometry.size.width - edgeDistance :
                        deviceOrientation == .landscapeRight ?
                            edgeDistance :
                            edgeDistance,
                    y: geometry.size.height / 2
                )
            }
            .zIndex(2)
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
                                if !isDragging {
                                    selectedTab = tab
                                    print("Selected tab: \(tab)")
                                }
                            } label: {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(selectedTab == tab ? selectedColor : unselectedColor)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                .frame(height: 60)
                .padding(.vertical, 20)
                .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.white.opacity(0.8))
            }
        }
    }
    
    // Helper computed property for tab offset
    
    /// The offset for the selected tab indicator.
    private var selectedTabOffset: CGFloat {
        let tabWidth = UIScreen.main.bounds.width / CGFloat(Tab.allCases.count)
        if let index = Tab.allCases.firstIndex(of: selectedTab) {
            return tabWidth * CGFloat(index) + (tabWidth - 50) / 2
        }
        return 0
    }
}

// Preview
#Preview {
    CustomTabBar(
        selectedTab: .constant(.home),
        isDragging: .constant(false),
        deviceOrientation: .portrait
    )
}

// End of file