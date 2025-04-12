//
//  ProfileInitialsView.swift
//  CycleMate
//

import SwiftUI

struct ProfileInitialsView: View {
    let user: User?
    var size: CGFloat = 100
    var fontSize: CGFloat = 20
    
    var body: some View {
        if let user = user {
            Circle()
                .fill(user.backgroundColor?.color ?? .gray)
                .frame(width: size, height: size)
                .overlay(
                    Text(user.initials)
                        .font(.system(size: fontSize, weight: .bold))
                        .foregroundColor(.white)
                )
        } else {
            Circle()
                .fill(Color.gray)
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: fontSize * 0.8))
                        .foregroundColor(.white)
                )
        }
    }
}

#Preview {
    let sampleUser = User(
        id: "sample",
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
    
    return Group {
        ProfileInitialsView(user: sampleUser)
        ProfileInitialsView(user: nil)
    }
}
