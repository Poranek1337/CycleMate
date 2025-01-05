// Your imports remain the same
import SwiftUI

struct AuthButton: View {
    // Properties remain the same
    let title: String
    let systemImage: String?
    let style: ButtonStyle
    let action: () async throws -> Void
    @State private var isLoading = false
    
    // Init remains the same
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
    
    enum ButtonStyle {
        case primary
        case outlined
    }
}

// Remove if extension as it's now in ViewModifiers.swift

// End of file. No additional code.
