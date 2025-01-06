//
//  ProfilePictureView.swift
//  CycleMate
//  dev.Poranek
//

// Your imports remain the same
import SwiftUI

/// A view that allows users to add or update their profile picture.
struct ProfilePictureView: View {
    // MARK: - Properties remain the same
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel: AuthViewModel
    @StateObject private var imagePickerModel = ImagePickerModel()
    @State private var animateContent = false
    @State private var showPhotoOptions = false
    @State private var offset: CGFloat = UIScreen.main.bounds.height
    @State private var showMainView = false
    
    // MARK: - Computed properties remain the same
    private var hasSelectedImage: Bool {
        viewModel.userProfileImage != nil
    }
    
    private var backgroundOpacity: Double {
        let progress = 1 - (offset / UIScreen.main.bounds.height)
        return Double(max(0, min(0.3, progress * 0.3)))
    }
    
    // MARK: - Initialization remains the same
    init(viewModel: AuthViewModel) {
        print(" ProfilePictureView initialized with viewModel")
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    // Main content section remains the same
                    VStack(spacing: 0) {
                        // Header section remains the same
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
                        
                        // Title and description section remains the same
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
                        
                        // Profile image circle remains the same
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
                        
                        // Bottom buttons remain the same
                        VStack(spacing: 15) {
                            Button {
                                print(" Choose photo button tapped")
                                showPhotoOptions = true
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
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
                                Task {
                                    if hasSelectedImage {
                                        print(" Uploading profile image...")
                                        await viewModel.updateProfileImage(image: viewModel.userProfileImage!)
                                        print(" Profile image upload completed")
                                        print(" Error state: \(viewModel.showError)")
                                    }
                                    
                                    if !viewModel.showError {
                                        print(" Setting showMainView to true")
                                        showMainView = true
                                    }
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
                    }
                    
                    // Updated photo selection card
                    if showPhotoOptions {
                        Color.black
                            .opacity(backgroundOpacity)
                            .ignoresSafeArea()
                            .onTapGesture {
                                dismissPhotoOptions()
                            }
                        
                        VStack(spacing: 0) {
                            // Handle indicator
                            Rectangle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 50, height: 5)
                                .cornerRadius(2.5)
                                .padding(.top, 8)
                                .padding(.bottom, 15)
                            
                            // Photo options buttons
                            VStack(spacing: 12) {
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
                            .padding(.bottom, 30)
                        }
                        .background(
                            Color(.systemBackground)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 25)
                                )
                        )
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .transition(.move(edge: .bottom))
                        .offset(y: offset)
                        .position(x: geometry.size.width / 2, y: geometry.size.height + (offset - 55))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newOffset = value.translation.height
                                    if newOffset > 0 {
                                        offset = newOffset
                                    }
                                }
                                .onEnded { value in
                                    if value.translation.height > 50 {
                                        dismissPhotoOptions()
                                    } else {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                            offset = 0
                                        }
                                    }
                                }
                        )
                    }
                }
                // Sheet modifiers remain the same
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
    
    // MARK: - Helper Methods remain the same
    private func dismissPhotoOptions() {
        print(" Dismissing photo options")
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            offset = UIScreen.main.bounds.height
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showPhotoOptions = false
        }
    }
}

#Preview {
    ProfilePictureView(viewModel: AuthViewModel())
}
