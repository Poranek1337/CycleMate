//
//  ProfileImageManager.swift
//  CycleMate
//

import SwiftUI
import CryptoKit
import ImageIO
import UniformTypeIdentifiers
import Foundation
import UIKit
import FirebaseStorage

class ProfileImageManager {
    static let shared = ProfileImageManager()
    
    private let fileManager = FileManager.default
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private let storage = Storage.storage().reference()
    
    private let compressionQuality: CGFloat = 0.8
    private let imageSize = CGSize(width: 500, height: 500)

    private var checksumVerificationEnabled = true
    
    private init() {
        print("📸 ProfileImageManager initialized")
    }
    
    func setChecksumVerification(enabled: Bool) {
        checksumVerificationEnabled = enabled
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
    
    // MARK: - Firebase Storage Methods
    func uploadProfileImage(_ image: UIImage, userId: String) async throws -> String {
        print("📤 Starting upload with userId")
        
        guard let normalizedImage = normalizeImage(image),
              let imageData = standardizedImageData(from: normalizedImage) else {
            throw ImageError.compressionFailed
        }
        
        // Hash userId dla bezpieczeństwa
        let hashedUserId = SHA256.hash(data: Data(userId.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
        
        let filename = "\(hashedUserId).jpg"
        let imageRef = storage.child("profile_images/\(filename)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        do {
            _ = try await imageRef.putDataAsync(imageData, metadata: metadata)
            let downloadURL = try await imageRef.downloadURL()
            
            // Save locally after successful upload
            try saveImageLocally(normalizedImage, withToken: userId)
            
            return downloadURL.absoluteString
        } catch {
            print("❌ Upload failed: \(error.localizedDescription)")
            throw ImageError.uploadFailed
        }
    }
    
    // MARK: - Local Storage Methods
    func saveImageLocally(_ image: UIImage, withToken token: String) throws -> URL {
        print("💾 Saving image locally")
        let hashedToken = SHA256.hash(data: Data(token.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
        
        let fileName = "\(hashedToken).jpg"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        guard let imageData = standardizedImageData(from: image) else {
            throw ImageError.compressionFailed
        }
        
        try imageData.write(to: fileURL)
        return fileURL
    }
    
    func loadLocalImage(withToken token: String) -> UIImage? {
        let hashedToken = SHA256.hash(data: Data(token.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
        
        let fileName = "\(hashedToken).jpg"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        guard let imageData = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    func removeLocalImage(withToken token: String) throws {
        print(" Attempting to remove local image")
        let hashedToken = SHA256.hash(data: Data(token.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
        
        let fileName = "\(hashedToken).jpg"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
            print("🗑️ Removed local image")
        } else {
            print(" No local image found to remove")
        }
    }
    
    // Compare images using checksum verification
    func areImagesEqual(localImage: UIImage, remoteImage: UIImage) -> Bool {
        if !checksumVerificationEnabled {
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
    
    // MARK: - Helper Methods
    private func normalizeImage(_ image: UIImage) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        return renderer.image { context in
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: imageSize))
            image.draw(in: CGRect(origin: .zero, size: imageSize))
        }
    }
    
    private func standardizedImageData(from image: UIImage) -> Data? {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, UTType.jpeg.identifier as CFString, 1, nil) else { return nil }
        
        let cleanMetadata = [kCGImageDestinationLossyCompressionQuality: compressionQuality] as [CFString : Any]
        
        guard let cgImage = image.cgImage else { return nil }
        CGImageDestinationAddImage(destination, cgImage, cleanMetadata as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        
        return data as Data
    }
    
    enum ImageError: Error {
        case compressionFailed
        case saveFailed
        case loadFailed
        case uploadFailed
    }
}
