//
//  AuthButton.swift
//  CycleMate
//  dev.Poranek
//

import SwiftUI

/// A customizable authentication button with loading state.
struct AuthButton: View {
    /// The title of the button.
    let title: String
    
    /// The system image name to display in the button.
    let systemImage: String?
    
    /// The style of the button.
    let style: ButtonStyle
    
    /// The action to perform when the button is tapped.
    let action: () async throws -> Void
    
    /// The loading state of the button.
    @State private var isLoading = false
    
    /// Initializes a new authentication button.
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - systemImage: The system image name to display in the button.
    ///   - style: The style of the button.
    ///   - action: The action to perform when the button is tapped.
    init(
        title: String,
        systemImage: String? = nil,
        style: ButtonStyle = .primary,
        action: @escaping () async throws -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button {
            guard !isLoading else { return }
            Task {
                isLoading = true
                do {
                    try await action()
                } catch {
                    // Error handling is done in the view model
                }
                isLoading = false
            }
        } label: {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.trailing, 8)
                } else if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.title2)
                }
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .if(style == .primary) { view in
                view.background(Color("second"))
            }
            .if(style == .outlined) { view in
                view.background(.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.gray, lineWidth: 1.5)
                    )
            }
            .cornerRadius(30)
            .foregroundColor(.primary)
            .opacity(isLoading ? 0.6 : 1)
        }
        .disabled(isLoading)
    }
    
    /// The style of the button.
    enum ButtonStyle {
        case primary
        case outlined
    }
}