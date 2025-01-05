//
//  ProfilePictureView.swift
//  CycleMate
//
//  Created by Poranek on 15/12/2024.
//

import SwiftUI

struct ProfilePictureView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel: AuthViewModel
    @StateObject private var imagePickerModel = ImagePickerModel()
    @State private var animateContent = false
    @State private var showPhotoOptions = false
    @State private var offset: CGFloat = UIScreen.main.bounds.height
    @State private var showMainView = false
    
    // Add computed property for button text
    private var hasSelectedImage: Bool {
        viewModel.userProfileImage != nil
    }
    
    // Background opacity computation
    private var backgroundOpacity: Double {
        let progress = 1 - (offset / UIScreen.main.bounds.height)
        return Double(max(0, min(0.3, progress * 0.3)))
    }
    
    // MARK: - Initialization
    init(viewModel: AuthViewModel) {
        print(" ProfilePictureView initialized with viewModel")
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        // Add navigation stack for programmatic navigation
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    // Main content
                    VStack(spacing: 0) {
                        // Header section
                        HStack(alignment: .top) {
                            Button(action: {
                                print(" User tapped back button")
                                dismiss()
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Title and description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Add profile picture ")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Personalize your profile with a photo. You can skip this step and add it later.")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                        
                        // Profile image view
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 200, height: 200)
                            
                            if let selectedImage = viewModel.userProfileImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 200)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 40)
                        
                        Spacer()
                        
                        // Modified bottom buttons with logging
                        VStack(spacing: 15) {
                            Button {
                                print(" Choose photo button tapped")
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    showPhotoOptions = true
                                    offset = 0
                                }
                            } label: {
                                Text("Choose a photo")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color("second"))
                                    .cornerRadius(30)
                            }
                            
                            Button {
                                print(" Continue/Maybe later button tapped")
                                if hasSelectedImage {
                                    print(" Uploading profile image...")
                                    Task {
                                        await viewModel.updateProfileImage(image: viewModel.userProfileImage!)
                                        print(" Profile image upload completed")
                                        print(" Error state: \(viewModel.showError)")
                                        if !viewModel.showError {
                                            print(" Setting showMainView to true")
                                            dismiss()
                                            showMainView = true
                                        }
                                    }
                                } else {
                                    print(" Skipping profile image, navigating to main view")
                                    dismiss()
                                    showMainView = true
                                }
                            } label: {
                                Text(hasSelectedImage ? "Continue" : "Maybe later")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .padding(.bottom, 20)
                    }
                    
                    // Photo selection card
                    if showPhotoOptions {
                        Color.black
                            .opacity(backgroundOpacity)
                            .ignoresSafeArea()
                            .onTapGesture {
                                dismissPhotoOptions()
                            }
                        
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 50, height: 5)
                                .cornerRadius(2.5)
                                .padding(.top, 12)
                            
                            VStack(spacing: 15) {
                                Button {
                                    print(" User tapped Take Photo")
                                    imagePickerModel.sourceType = .camera
                                    imagePickerModel.showImagePicker = true
                                    dismissPhotoOptions()
                                } label: {
                                    Text("Take photo")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                }
                                
                                Button {
                                    print(" User tapped Add from Library")
                                    imagePickerModel.sourceType = .photoLibrary
                                    imagePickerModel.showImagePicker = true
                                    dismissPhotoOptions()
                                } label: {
                                    Text("Add from library")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                }
                            }
                            .padding(.horizontal, 25)
                            .padding(.vertical, 20)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(25, corners: [.topLeft, .topRight])
                        .offset(y: offset)
                        .ignoresSafeArea(.container, edges: .bottom)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newOffset = value.translation.height
                                    if newOffset > 0 {
                                        offset = newOffset
                                    }
                                }
                                .onEnded { value in
                                    if value.translation.height > 100 {
                                        dismissPhotoOptions()
                                    } else {
                                        withAnimation(.spring()) {
                                            offset = 0
                                        }
                                    }
                                }
                        )
                    }
                }
                .sheet(isPresented: $imagePickerModel.showImagePicker) {
                    ImagePickerView(
                        sourceType: imagePickerModel.sourceType,
                        selectedImage: $imagePickerModel.selectedImage
                    ) {
                        if let _ = imagePickerModel.selectedImage {
                            imagePickerModel.showCropper = true
                        }
                    }
                    .ignoresSafeArea()
                }
                .sheet(isPresented: $imagePickerModel.showCropper) {
                    if let image = imagePickerModel.selectedImage {
                        ImageCropperView(image: image) { croppedImage in
                            viewModel.userProfileImage = croppedImage
                            imagePickerModel.reset()
                        }
                    }
                }
                .fullScreenCover(isPresented: $showMainView) {
                    MainTabView()
                }
                .alert("Error", isPresented: $viewModel.showError) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(viewModel.errorMessage)
                }
            }
            .onAppear {
                print(" View appeared")
                withAnimation(.easeOut(duration: 0.8)) {
                    animateContent = true
                }
            }
            .onChange(of: showMainView) { newValue in
                print(" showMainView changed to: \(newValue)")
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - Helper Methods
    private func dismissPhotoOptions() {
        print(" Dismissing photo options")
        withAnimation(.spring()) {
            offset = UIScreen.main.bounds.height
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showPhotoOptions = false
        }
    }
}

// Add preview
#Preview {
    ProfilePictureView(viewModel: AuthViewModel())
}
