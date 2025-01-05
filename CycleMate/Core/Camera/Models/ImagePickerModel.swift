//
//  ImagePickerModel.swift
//  CycleMate
//

import SwiftUI
import PhotosUI

class ImagePickerModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var showImagePicker = false
    @Published var showCropper = false
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    func showPicker() {
        sourceType = .photoLibrary
        showImagePicker = true
    }
    
    func showCamera() {
        sourceType = .camera
        showImagePicker = true
    }
    
    func handleSelectedImage(_ image: UIImage?) {
        self.selectedImage = image
        showImagePicker = false
        if image != nil {
            showCropper = true
        }
    }
    
    func reset() {
        selectedImage = nil
        showImagePicker = false
        showCropper = false
    }
}

// End of file. No additional code.
