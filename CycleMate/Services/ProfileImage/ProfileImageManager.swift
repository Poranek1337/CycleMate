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

class ProfileImageManager {
    static let shared = ProfileImageManager()
    
    private let fileManager = FileManager.default
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private let compressionQuality: CGFloat = 0.8
    private let imageSize = CGSize(width: 500, height: 500)
    private var checksumVerificationEnabled = true
    
    private init() {
        print("📸 ProfileImageManager initialized")
    }
    
    func setChecksumVerification(enabled: Bool) {
        checksumVerificationEnabled = enabled
    }
    
    // MARK: - Image Upload
    func uploadProfileImage(_ image: UIImage, token: String) async throws -> String {
        print("\n🔄 Rozpoczęcie procesu wysyłania zdjęcia...")
        
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BackendBaseURL") as? String else {
            throw ImageError.configurationError
        }
        
        let uploadURL = URL(string: "\(baseURL)/api/auth/upload-profile-image")!
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard let imageData = standardizedImageData(from: image) else {
            throw ImageError.compressionFailed
        }
        
        var body = Data()
        let lineBreak = "\r\n"
        
        body.append("--\(boundary)\(lineBreak)")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\(lineBreak)")
        body.append("Content-Type: image/jpeg\(lineBreak)\(lineBreak)")
        body.append(imageData)
        body.append("\(lineBreak)")
        body.append("--\(boundary)--\(lineBreak)")
        
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ImageError.invalidResponse
            }
            
            print("📥 Status odpowiedzi: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Odpowiedź serwera: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                if let imageUrl = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    print("✅ Zdjęcie wysłane pomyślnie")
                    print("📍 URL zdjęcia: \(imageUrl)\n")
                    _ = try saveImageLocally(image, withToken: token)
                    return imageUrl
                }
                throw ImageError.invalidResponse
                
            case 401:
                throw ImageError.unauthorized
                
            default:
                if let errorMessage = String(data: data, encoding: .utf8) {
                    throw ImageError.serverError(errorMessage)
                }
                throw ImageError.uploadFailed
            }
        } catch {
            if error is ImageError {
                throw error
            }
            throw ImageError.uploadFailed
        }
    }
    
    private func appendFormData(_ data: inout Data, string: String) {
        if let stringData = string.data(using: .utf8) {
            data.append(stringData)
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
        print("🗑 Attempting to remove local image")
        let hashedToken = SHA256.hash(data: Data(token.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
        
        let fileName = "\(hashedToken).jpg"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
            print("✅ Removed local image")
        }
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
    
    private func verifyResponseFormat(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 401:
            throw ImageError.unauthorized
        case 413:
            throw ImageError.fileTooLarge
        case 415:
            throw ImageError.unsupportedMediaType
        default:
            if let errorMessage = String(data: data, encoding: .utf8) {
                throw ImageError.serverError(errorMessage)
            }
            throw ImageError.uploadFailed
        }
    }
    
    enum ImageError: Error, LocalizedError {
        case compressionFailed
        case saveFailed
        case loadFailed
        case uploadFailed
        case invalidResponse
        case configurationError
        case unauthorized
        case fileTooLarge
        case unsupportedMediaType
        case serverError(String)
        
        var errorDescription: String? {
            switch self {
            case .compressionFailed: return "Failed to compress image"
            case .saveFailed: return "Failed to save image locally"
            case .loadFailed: return "Failed to load image"
            case .uploadFailed: return "Failed to upload image"
            case .invalidResponse: return "Invalid response from server"
            case .configurationError: return "Missing configuration"
            case .unauthorized: return "Unauthorized - please log in again"
            case .fileTooLarge: return "Image file is too large"
            case .unsupportedMediaType: return "Unsupported image format"
            case .serverError(let message): return message
            }
        }
    }
}
