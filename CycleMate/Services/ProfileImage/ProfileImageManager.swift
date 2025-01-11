//
//  ProfileImageManager.swift
//  CycleMate
//

import SwiftUI
import CryptoKit
import ImageIO
import UniformTypeIdentifiers

class ProfileImageManager {
    static let shared = ProfileImageManager()
    
    private let fileManager = FileManager.default
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    private let compressionQuality: CGFloat = 0.8
    private let imageSize = CGSize(width: 500, height: 500) // Standardized size

    private var skipChecksumVerification = false

    private init() {
        print(" ProfileImageManager initialized")
    }
    
    func setChecksumVerification(enabled: Bool) {
        skipChecksumVerification = !enabled
    }
    
    private func generateChecksum(for data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func compareImageData(_ data1: Data, _ data2: Data) -> Bool {
        let checksum1 = generateChecksum(for: data1)
        let checksum2 = generateChecksum(for: data2)
        print("🔍 Checksum comparison:")
        print("   Local: \(checksum1)")
        print("   Remote: \(checksum2)")
        return checksum1 == checksum2
    }
    
    private func normalizeImage(_ image: UIImage) -> UIImage? {
        print("🔄 Normalizing image...")
        
        // Scale the image to standard size
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let normalizedImage = renderer.image { context in
            // Clear background to ensure consistency
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: imageSize))
            
            // Draw image with aspect fit
            let rect = CGRect(origin: .zero, size: imageSize)
            image.draw(in: rect)
        }
        
        return normalizedImage
    }
    
    private func standardizedImageData(from image: UIImage) -> Data? {
        guard let normalizedImage = normalizeImage(image) else { return nil }
        
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, "public.jpeg" as CFString, 1, nil) else { return nil }
        
        // Remove all metadata
        let cleanMetadata = [kCGImageDestinationLossyCompressionQuality: compressionQuality] as [CFString : Any]
        
        guard let cgImage = normalizedImage.cgImage else { return nil }
        CGImageDestinationAddImage(destination, cgImage, cleanMetadata as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        
        return data as Data
    }
    
    // Save image to local storage
    func saveImageLocally(_ image: UIImage, forUserId userId: String) throws -> URL {
        print(" Starting to save image locally for user: \(userId)")
        let fileName = "profile_\(userId).jpg"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        guard let imageData = standardizedImageData(from: image) else {
            print("❌ Failed to standardize image for local storage")
            throw ImageError.compressionFailed
        }
        
        print(" Writing image data to: \(fileURL.path)")
        try imageData.write(to: fileURL)
        print("💾 Saved new profile image")
        let savedChecksum = generateChecksum(for: imageData)
        print("📝 Saved image checksum: \(savedChecksum)")
        return fileURL
    }
    
    // Load image from local storage
    func loadLocalImage(forUserId userId: String) -> UIImage? {
        print(" Attempting to load local image for user: \(userId)")
        let fileName = "profile_\(userId).jpg"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        guard let imageData = try? Data(contentsOf: fileURL) else {
            print(" No local image found for user: \(userId)")
            return nil
        }
        print(" Successfully loaded local image")
        let loadedChecksum = generateChecksum(for: imageData)
        print("📝 Loaded image checksum: \(loadedChecksum)")
        return UIImage(data: imageData)
    }
    
    // Compare images using checksum verification
    func areImagesEqual(localImage: UIImage, remoteImage: UIImage) -> Bool {
        if skipChecksumVerification {
            print("🔓 Skipping checksum verification")
            return true
        }
        
        print("\n📊 Starting image comparison")
        print("----------------------------")
        
        // Generate standardized data for both images
        guard let localData = standardizedImageData(from: localImage),
              let remoteData = standardizedImageData(from: remoteImage) else {
            print("❌ Failed to standardize images for comparison")
            return false
        }
        
        // Compare file sizes
        let localFileSize = localData.count
        let remoteFileSize = remoteData.count
        print("📏 File sizes:")
        print("   Local: \(localFileSize) bytes")
        print("   Remote: \(remoteFileSize) bytes")
        
        if localFileSize != remoteFileSize {
            print("❌ Images have different file sizes after standardization")
        }
        
        // Perform detailed comparison
        let areEqual = compareImageData(localData, remoteData)
        print("\n🔍 Final comparison result: \(areEqual ? "✅ Images are equal" : "❌ Images are different")")
        print("----------------------------\n")
        
        return areEqual
    }
    
    // Remove local image
    func removeLocalImage(forUserId userId: String) throws {
        print(" Attempting to remove local image for user: \(userId)")
        let fileName = "profile_\(userId).jpg"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
            print("🗑️ Removed local image for user: \(userId)")
        } else {
            print(" No local image found to remove")
        }
    }
    
    enum ImageError: Error {
        case compressionFailed
        case saveFailed
        case loadFailed
    }
}
