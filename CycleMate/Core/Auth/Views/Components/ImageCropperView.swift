//
//  ImageCropperView.swift
//  CycleMate
//
//  Created by Poranek on 15/12/2024.
//

// Your imports remain the same
import SwiftUI

struct ImageCropperView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    let image: UIImage
    let onCrop: (UIImage) -> Void
    
    // MARK: - View Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color
                Color.black
                    .ignoresSafeArea()
                
                // Main content
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding()
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Centered image with crop overlay
                    ZStack {
                        GeometryReader { imageGeometry in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(
                                    width: min(geometry.size.width, geometry.size.height) * 0.8,
                                    height: min(geometry.size.width, geometry.size.height) * 0.8
                                )
                                .scaleEffect(max(scale, calculateMinimumScale(for: image, in: imageGeometry)))
                                .offset(limitOffset(offset, in: imageGeometry))
                                .gesture(
                                    SimultaneousGesture(
                                        DragGesture()
                                            .onChanged { value in
                                                let newOffset = CGSize(
                                                    width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height
                                                )
                                                offset = limitOffset(newOffset, in: imageGeometry)
                                            }
                                            .onEnded { _ in
                                                lastOffset = offset
                                            },
                                        MagnificationGesture()
                                            .onChanged { value in
                                                let minScale = calculateMinimumScale(for: image, in: imageGeometry)
                                                let newScale = lastScale * value
                                                scale = max(newScale, minScale)
                                            }
                                            .onEnded { _ in
                                                let minScale = calculateMinimumScale(for: image, in: imageGeometry)
                                                scale = max(scale, minScale)
                                                lastScale = scale
                                            }
                                    )
                                )
                        }
                        .frame(
                            width: min(geometry.size.width, geometry.size.height) * 0.8,
                            height: min(geometry.size.width, geometry.size.height) * 0.8
                        )
                        .clipShape(Circle())
                        
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(
                                width: min(geometry.size.width, geometry.size.height) * 0.8,
                                height: min(geometry.size.width, geometry.size.height) * 0.8
                            )
                    }
                    
                    Spacer()
                    
                    // Bottom buttons
                    HStack(spacing: 15) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                        }
                        
                        Button {
                            cropImage(geometry: geometry)
                        } label: {
                            Text("Set")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color("second"))
                                .cornerRadius(30)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            // Set initial scale to ensure image always fills the circle
            DispatchQueue.main.async {
                let screenWidth = UIScreen.main.bounds.width
                let circleSize = screenWidth * 0.8
                let imageSize = image.size
                let widthRatio = circleSize / imageSize.width
                let heightRatio = circleSize / imageSize.height
                scale = max(widthRatio, heightRatio) * 1.1 // Add 10% to ensure complete coverage
                lastScale = scale
            }
        }
    }
    
    // MARK: - Helper Methods
    private func calculateMinimumScale(for image: UIImage, in geometry: GeometryProxy) -> CGFloat {
        let circleSize = min(geometry.size.width, geometry.size.height)
        let imageSize = image.size
        let widthRatio = circleSize / imageSize.width
        let heightRatio = circleSize / imageSize.height
        return max(widthRatio, heightRatio) * 1.1 // Add 10% to ensure complete coverage
    }
    
    private func limitOffset(_ offset: CGSize, in geometry: GeometryProxy) -> CGSize {
        let circleSize = min(geometry.size.width, geometry.size.height)
        let scaledImageSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        
        let maxOffset = CGSize(
            width: (scaledImageSize.width - circleSize) / 2,
            height: (scaledImageSize.height - circleSize) / 2
        )
        
        return CGSize(
            width: max(-maxOffset.width, min(maxOffset.width, offset.width)),
            height: max(-maxOffset.height, min(maxOffset.height, offset.height))
        )
    }
    
    private func cropImage(geometry: GeometryProxy) {
        let renderer = ImageRenderer(content:
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(
                    width: min(geometry.size.width, geometry.size.height) * 0.8,
                    height: min(geometry.size.width, geometry.size.height) * 0.8
                )
                .scaleEffect(scale)
                .offset(offset)
                .clipShape(Circle())
        )
        
        if let croppedImage = renderer.uiImage {
            onCrop(croppedImage)
        }
        
        dismiss()
    }
}

// Preview remains the same
#Preview {
    ImageCropperView(image: UIImage(systemName: "person.fill")!) { _ in }
}

// End of file. No additional code.
