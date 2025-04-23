//
//  ProfileImageView.swift
//  CycleMate
//
//  Created by Poranek on 30/03/2025.
//

import SwiftUI

struct ProfileImageView: View {
    let user: User?
    let size: CGFloat
    @State private var profileImage: UIImage?
    
    init(user: User?, size: CGFloat = 50) {
        self.user = user
        self.size = size
    }
    
    var body: some View {
        Group {
            if let user = user {
                if let image = profileImage {
                    // Wyświetl załadowane zdjęcie
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                } else if !user.photoURL.isEmpty {
                    // Próbuj załadować zdjęcie z cache lub URL
                    AsyncImage(url: URL(string: user.photoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: size, height: size)
                                .clipShape(Circle())
                                .onAppear {
                                    // Zapisz zdjęcie do cache przy pierwszym załadowaniu
                                    if let token = user.token,
                                       let uiImage = image.asUIImage() {
                                        Task {
                                            try? ProfileImageManager.shared.saveImageLocally(uiImage, withToken: token)
                                        }
                                    }
                                }
                        case .empty, .failure:
                            ProfileInitialsView(user: user, size: size)
                        @unknown default:
                            ProfileInitialsView(user: user, size: size)
                        }
                    }
                    .task {
                        // Próbuj załadować z lokalnego cache
                        if let token = user.token {
                            profileImage = ProfileImageManager.shared.loadLocalImage(withToken: token)
                        }
                    }
                } else {
                    ProfileInitialsView(user: user, size: size)
                }
            } else {
                ProfileInitialsView(user: nil, size: size)
            }
        }
        .frame(width: size, height: size)
    }
}

// Helper do konwersji Image na UIImage
extension Image {
    @MainActor
    func asUIImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        return renderer.uiImage
    }
}

#Preview {
    let sampleUser = User(
        id: "preview-id",
        firstName: "John",
        lastName: "Doe",
        email: "john@example.com",
        photoURL: "",
        createdAt: Date(),
        dateOfBirth: nil,
        provider: "email",
        isProfileCompleted: true,
        backgroundColor: nil
    )
    
    return HStack {
        ProfileImageView(user: sampleUser, size: 50)
        ProfileImageView(user: sampleUser, size: 100)
    }
}
