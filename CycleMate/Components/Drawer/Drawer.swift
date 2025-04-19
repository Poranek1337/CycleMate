//
//  Drawer.swift
//  CycleMate
//

import SwiftUI

struct Drawer<Content: View>: View {
    @Binding var isExpanded: Bool
    @Binding var isHalfExpanded: Bool
    
    @State private var offset: CGFloat = UIScreen.main.bounds.height
    @State private var lastOffset: CGFloat = UIScreen.main.bounds.height
    
    let minHeight: CGFloat
    let halfHeight: CGFloat
    let fullHeight: CGFloat
    let keyboardHeight: CGFloat
    
    private let cornerRadius: CGFloat = 20
    private let indicatorHeight: CGFloat = 5
    private let indicatorWidth: CGFloat = 80
    
    @ViewBuilder let content: Content
    
    init(
        isExpanded: Binding<Bool>,
        isHalfExpanded: Binding<Bool>,
        minHeight: CGFloat = 70,
        halfHeight: CGFloat = UIScreen.main.bounds.height * 0.45,
        fullHeight: CGFloat = UIScreen.main.bounds.height * 0.85,
        keyboardHeight: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self._isExpanded = isExpanded
        self._isHalfExpanded = isHalfExpanded
        self.minHeight = minHeight
        self.halfHeight = halfHeight
        self.fullHeight = fullHeight
        self.keyboardHeight = keyboardHeight
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if isExpanded {
                    Color.clear
                        .contentShape(Rectangle())
                        .allowsHitTesting(true)
                        .simultaneousGesture(
                            TapGesture()
                                .onEnded { _ in
                                    withAnimation(.spring()) {
                                        dismiss()
                                    }
                                }
                        )
                        .ignoresSafeArea()
                }
                
                VStack(spacing: 0) {
                    ZStack {
                        Color.clear
                            .frame(height: 40)
                        
                        Capsule()
                            .fill(.secondary)
                            .frame(width: indicatorWidth, height: indicatorHeight)
                    }
                    .contentShape(Rectangle())
                    
                    content
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(Material.thin)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .offset(y: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let translation = value.translation.height
                            let newOffset = lastOffset + translation
                            offset = max(0, min(newOffset, geometry.size.height))
                        }
                        .onEnded { value in
                            let velocity = value.predictedEndTranslation.height - value.translation.height
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                if velocity > 500 {
                                    offset = geometry.size.height - fullHeight
                                    isHalfExpanded = false
                                } else if velocity < -500 {
                                    dismiss()
                                    return
                                } else {
                                    let positions = [
                                        geometry.size.height - fullHeight,
                                        geometry.size.height - halfHeight,
                                        geometry.size.height
                                    ]
                                    
                                    let closest = positions.min(by: { abs($0 - offset) < abs($1 - offset) }) ?? positions[1]
                                    
                                    if closest == positions[0] {
                                        offset = positions[0]
                                        isHalfExpanded = false
                                    } else if closest == positions[1] {
                                        offset = positions[1]
                                        isHalfExpanded = true
                                    } else {
                                        dismiss()
                                        return
                                    }
                                }
                            }
                            
                            lastOffset = offset
                        }
                )
                .ignoresSafeArea(edges: .bottom)
                .shadow(radius: 10)
            }
            .onChange(of: isExpanded) { _, expanded in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if expanded {
                        offset = isHalfExpanded ?
                            geometry.size.height - halfHeight :
                            geometry.size.height - fullHeight
                    } else {
                        offset = geometry.size.height
                    }
                    lastOffset = offset
                }
            }
            .onChange(of: isHalfExpanded) { _, half in
                if isExpanded {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        offset = half ?
                            geometry.size.height - halfHeight :
                            geometry.size.height - fullHeight
                        lastOffset = offset
                    }
                }
            }
            .onChange(of: keyboardHeight) { _, _ in
                if isExpanded {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        offset = calculateOffset(geometry)
                        lastOffset = offset
                    }
                }
            }
        }
    }
    
    private func calculateOffset(_ geometry: GeometryProxy) -> CGFloat {
        if !isExpanded {
            return geometry.size.height
        }
        
        let baseOffset = isHalfExpanded ?
            geometry.size.height - halfHeight :
            geometry.size.height - fullHeight
        
        if keyboardHeight > 0 {
            return min(baseOffset, geometry.size.height - keyboardHeight - minHeight)
        }
        
        return baseOffset
    }
    
    private func dismiss() {
        offset = UIScreen.main.bounds.height
        isExpanded = false
        isHalfExpanded = false
        lastOffset = offset
    }
}
