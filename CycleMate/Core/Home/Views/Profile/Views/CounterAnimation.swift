//
//  CounterAnimation.swift
//  CycleMate
//
//  Created by Poranek on 29/03/2025.
//

import SwiftUI

struct CounterAnimation: ViewModifier {
    let end: Double
    let duration: Double
    let decimalPlaces: Int
    let animation: Animation
    @State private var value: Double = 0
    
    init(
        end: Double,
        duration: Double = 2.0,
        decimalPlaces: Int = 1,
        animation: Animation = .easeOut(duration: 2.0)
    ) {
        self.end = end
        self.duration = duration
        self.decimalPlaces = decimalPlaces
        self.animation = animation
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                withAnimation(animation) {
                    value = end
                }
            }
            .onChange(of: end) { newValue in
                withAnimation(animation) {
                    value = newValue
                }
            }
    }
    
    var displayValue: String {
        String(format: "%.\(decimalPlaces)f", value)
    }
}

extension View {
    func animatedCounter(
        end: Double,
        duration: Double = 2.0,
        decimalPlaces: Int = 1,
        animation: Animation = .easeOut(duration: 2.0)
    ) -> some View {
        modifier(CounterAnimation(
            end: end,
            duration: duration,
            decimalPlaces: decimalPlaces,
            animation: animation
        ))
    }
}
