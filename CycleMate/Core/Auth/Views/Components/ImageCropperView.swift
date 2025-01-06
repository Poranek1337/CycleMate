//
//  ImageCropperView.swift
//  CycleMate
//  dev.Poranek
//

import SwiftUI

struct ImageCropperView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var isDragging = false
    let image: UIImage
    let onCrop: (UIImage) -> Void
    
    // MARK: - View Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    // Header with close button
                    HStack {
                        Button(action: { dismiss() }) {
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
                    
                    // Image cropper
                    ZStack {
                        let circleSize = min(geometry.size.width, geometry.size.height) * 0.8
                        
                        GeometryReader { _ in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: circleSize, height: circleSize)
                                .scaleEffect(scale)
                                .offset(offset)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            isDragging = true
                                            let newOffset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                            // Allow free movement during drag
                                            offset = newOffset
                                        }
                                        .onEnded { _ in
                                            isDragging = false
                                            lastOffset = offset
                                            // Animate back to bounds with spring effect
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                offset = limitOffset(offset, circleSize: circleSize)
                                                lastOffset = offset
                                            }
                                        }
                                )
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let delta = value / lastScale
                                            lastScale = value
                                            
                                            // Allow free scaling during gesture
                                            scale *= delta
                                        }
                                        .onEnded { _ in
                                            lastScale = 1.0
                                            // Animate to acceptable scale with spring effect
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                scale = max(1.0, scale)
                                                offset = limitOffset(offset, circleSize: circleSize)
                                            }
                                        }
                                )
                        }
                        .frame(width: circleSize, height: circleSize)
                        .clipShape(Circle())
                        
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: circleSize, height: circleSize)
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
    }
    
    // MARK: - Helper Methods
    
    private func limitOffset(_ offset: CGSize, circleSize: CGFloat) -> CGSize {
        let imageSize = image.size
        let baseScale = max(circleSize / imageSize.width, circleSize / imageSize.height)
        let scaledImageSize = CGSize(
            width: imageSize.width * baseScale * scale,
            height: imageSize.height * baseScale * scale
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
        let circleSize = min(geometry.size.width, geometry.size.height) * 0.8
        let renderer = ImageRenderer(content:
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: circleSize, height: circleSize)
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

#Preview {
    ImageCropperView(image: UIImage(systemName: "person.fill")!) { _ in }
}

