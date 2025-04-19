//
//  CounterAnimation.swift
//  CycleMate
//
//  Created by Poranek on 29/03/2025.
//

import SwiftUI

struct DigitView: View {
    let digit: String
    let animation: Animation
    
    var body: some View {
        Text(digit)
            .transition(.asymmetric(
                insertion: .move(edge: .bottom),
                removal: .move(edge: .top)
            ))
    }
}

struct CounterAnimation: ViewModifier {
    let end: Double
    let duration: Double
    let decimalPlaces: Int
    let animation: Animation
    
    @State private var currentValue: Double = 0
    @State private var displayedString: String = "0"
    
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
        Text(displayedString)
            .onAppear {
                animateCounter()
            }
            .onChange(of: end) { _, newValue in
                currentValue = 0
                animateCounter(to: newValue)
            }
    }
    
    private func animateCounter(to value: Double? = nil) {
        let target = value ?? end
        let stepCount = Int(duration * 60) // 60 FPS
        let stepValue = (target - currentValue) / Double(stepCount)
        
        for i in 0..<stepCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)/60.0) {
                withAnimation(animation) {
                    self.currentValue += stepValue
                    self.displayedString = String(format: "%.\(decimalPlaces)f", self.currentValue)
                    
                    // Set exact value when we reach the end
                    if i == stepCount - 1 {
                        self.currentValue = target
                        self.displayedString = String(format: "%.\(decimalPlaces)f", target)
                    }
                }
            }
        }
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
