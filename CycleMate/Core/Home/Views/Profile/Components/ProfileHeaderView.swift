//
//  ProfileHeader.swift
//  CycleMate
//
//  Created by Poranek on 30/03/2025.
//

import SwiftUI

struct ProfileHeader: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(width: 50, height: 5)
                .cornerRadius(2.5)
                .frame(maxWidth: .infinity)
                .padding(.top, 15)
                .padding(.bottom, 10)
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)
            .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
            
            if let user = authViewModel.currentUser {
                VStack(spacing: 12) {
                    ProfileImageView(user: user, size: 100)
                    Text(user.fullName)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                }
                .padding(.top, 20)
            }
        }
    }
}

#Preview {
    ProfileHeader()
        .environmentObject(AuthViewModel())
}
