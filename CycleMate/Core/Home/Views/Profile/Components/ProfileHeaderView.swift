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
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        // TODO: Add settings action
                    }) {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
            
            VStack(spacing: 12) {
                ProfileImageView(user: authViewModel.currentUser, size: 100)
                if let user = authViewModel.currentUser {
                    Text(user.fullName)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                } else {
                    Text("User")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                }
            }
            .padding(.top, 20)
        }
    }
}

#Preview {
    ProfileHeader()
        .environmentObject(AuthViewModel())
}
