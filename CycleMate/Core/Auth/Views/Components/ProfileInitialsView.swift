//
//  ProfileInitialsView.swift
//  CycleMate
//

import SwiftUI

struct ProfileInitialsView: View {
    // Remove AuthViewModel as we don't need it anymore
    let user: User?
    var size: CGFloat = 50
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
        }
    }
}

#Preview {
    ProfileInitialsView(user: nil)
}
