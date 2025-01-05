//
//  ImagePickerView.swift
//  CycleMate
//  dev.Poranek
//

import SwiftUI
import UIKit

/// A view that presents an image picker interface to the user.
struct ImagePickerView: UIViewControllerRepresentable {
    // MARK: - Properties
    
    /// The source type for the image picker (e.g., photo library, camera).
    var sourceType: UIImagePickerController.SourceType
    
    /// The binding to the selected image.
    @Binding var selectedImage: UIImage?
    
    /// The action to perform when the image picking is finished.
    var didFinishPicking: () -> Void
    
    // MARK: - UIViewControllerRepresentable
    
    /// Creates the `UIImagePickerController` instance.
    /// - Parameter context: The context for coordinating with the system.
    /// - Returns: A configured `UIImagePickerController` instance.
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    /// Updates the `UIImagePickerController` instance.
    /// - Parameters:
    ///   - uiViewController: The `UIImagePickerController` instance.
    ///   - context: The context for coordinating with the system.
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    /// Creates the coordinator for the image picker.
    /// - Returns: A new `Coordinator` instance.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    /// A coordinator to handle image picker delegate methods.
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        /// The parent `ImagePickerView` instance.
        let parent: ImagePickerView
        
        /// Initializes a new `Coordinator` instance.
        /// - Parameter parent: The parent `ImagePickerView` instance.
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        /// Called when the user picks an image.
        /// - Parameters:
        ///   - picker: The image picker controller.
        ///   - info: A dictionary containing the original image.
        func imagePickerController(_ picker: UIImagePickerController,
                                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.didFinishPicking()
            picker.dismiss(animated: true)
        }
        
        /// Called when the user cancels the image picker.
        /// - Parameter picker: The image picker controller.
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// Preview remains the same
#Preview {
    ImagePickerView(sourceType: .photoLibrary, selectedImage: .constant(nil), didFinishPicking: {})
}