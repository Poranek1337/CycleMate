//
//  ProfileImageView.swift
//  CycleMate
//
//  Created by Poranek on 30/03/2025.
//

import SwiftUI

struct ProfileImageView: View {
    let user: User
    let size: CGFloat
    
    init(user: User, size: CGFloat = 50) {
        self.user = user
        self.size = size
    }
    
    var body: some View {
        if !user.photoURL.isEmpty {
            if let localImage = ProfileImageManager.shared.loadLocalImage(forUserId: user.id) {
                Image(uiImage: localImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                AsyncImage(url: URL(string: user.photoURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                } placeholder: {
                    ProfileInitialsView(user: user)
                        .frame(width: size, height: size)
                }
            }
        } else {
            ProfileInitialsView(user: user)
                .frame(width: size, height: size)
        }
    }
}

#Preview {
    let sampleUser = User(
        id: "preview-id",
        firstName: "Pawel",
        lastName: "Nierdoka",
        email: "pawel@example.com",
        photoURL: "",
        createdAt: Date(),
        dateOfBirth: nil,
        provider: "email",
        isProfileCompleted: true,
        backgroundColor: nil
    )
    
    return ProfileImageView(user: sampleUser, size: 50)
}
