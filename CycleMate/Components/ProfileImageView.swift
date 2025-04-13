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
    
    init(user: User?, size: CGFloat = 50) {
        self.user = user
        self.size = size
    }
    
    var body: some View {
        Group {
            if let user = user {
                if !user.photoURL.isEmpty {
                    if let token = user.token,
                       let localImage = ProfileImageManager.shared.loadLocalImage(withToken: token) {
                        Image(uiImage: localImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    } else {
                        AsyncImage(url: URL(string: user.photoURL)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: size, height: size)
                                .clipShape(Circle())
                        } placeholder: {
                            ProfileInitialsView(user: user, size: size)
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

#Preview {
    let sampleUser = User(
        id: "preview-id",
        firstName: "John",
        lastName: "Doe",
        email: "John@example.com",
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
