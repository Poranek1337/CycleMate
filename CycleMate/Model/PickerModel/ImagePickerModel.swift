//
//  ImagePickerModel.swift
//  CycleMate
//
//  Created by Poranek on 15/12/2024.
//

import SwiftUI
import PhotosUI

/// A model that handles image picking and cropping.
class ImagePickerModel: ObservableObject {
    /// The selected image.
    @Published var selectedImage: UIImage?
    
    /// A flag indicating if the image picker should be shown.
    @Published var showImagePicker = false
    
    /// A flag indicating if the image cropper should be shown.
    @Published var showCropper = false
    
    /// The source type for the image picker (e.g., photo library, camera).
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    /// Shows the image picker with the photo library as the source type.
    func showPicker() {
        sourceType = .photoLibrary
        showImagePicker = true
    }
    
    /// Shows the image picker with the camera as the source type.
    func showCamera() {
        sourceType = .camera
        showImagePicker = true
    }
    
    /// Handles the selected image.
    /// - Parameter image: The selected image.
    func handleSelectedImage(_ image: UIImage?) {
        self.selectedImage = image
        showImagePicker = false
        if image != nil {
            showCropper = true
        }
    }
    
    /// Resets the image picker model.
    func reset() {
        selectedImage = nil
        showImagePicker = false
        showCropper = false
    }
}

// End of file. No additional code.