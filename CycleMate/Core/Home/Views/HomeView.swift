//
//  HomeView.swift
//  CycleMate
//

import SwiftUI

struct HomeView: View {
    // Add AuthViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    // Add state to track image loading
    @State private var isCheckingImage = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header Section
                HStack {
                    VStack(alignment: .leading) {
                        Text("Hi, \(authViewModel.currentUser?.firstName ?? "User")!")
                            .font(.title)
                            .bold()
                        Text("Where will we go today?")
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Update Profile Picture section
                    if let user = authViewModel.currentUser {
                        if !user.photoURL.isEmpty {
                            if let localImage = ProfileImageManager.shared.loadLocalImage(forUserId: user.id) {
                                Image(uiImage: localImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                AsyncImage(url: URL(string: user.photoURL)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                } placeholder: {
                                    ProfileInitialsView(user: user)
                                }
                            }
                        } else {
                            ProfileInitialsView(user: user)
                        }
                    } else {
                        ProfileInitialsView(user: nil)
                    }
                }
                .padding()
                .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
                
                // Map Preview Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Graham Ave")
                        .bold()
                    Text("Patterson, St")
                    
                    HStack {
                        Text("4.3 Mile")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        
                        Text("62 Min")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)
                .padding(.horizontal)
                
                // Stats Grid
                HStack(spacing: 15) {
                    // Bikes Section
                    VStack {
                        Text("MY BIKES")
                            .bold()
                        Rectangle()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.yellow.opacity(0.3))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(20)
                    
                    // Stats Section
                    VStack(spacing: 15) {
                        // Calories Card
                        VStack(alignment: .leading) {
                            Text("Calories")
                                .foregroundColor(.gray)
                            Text("923")
                                .font(.title2)
                                .bold()
                            Text("KCal")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(20)
                        
                        // Target Card
                        VStack(alignment: .leading) {
                            Text("Target")
                                .foregroundColor(.gray)
                            Text("20")
                                .font(.title2)
                                .bold()
                            Text("Miles in a Week")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(20)
                    }
                }
                .padding(.horizontal)
                
                // Monthly Chart Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Monthly Chart")
                        .bold()
                    Text("By Minutes")
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .bottom, spacing: 20) {
                        Rectangle()
                            .frame(width: 30, height: 100)
                            .foregroundColor(.gray.opacity(0.3))
                        Rectangle()
                            .frame(width: 30, height: 60)
                            .foregroundColor(.gray.opacity(0.3))
                        Rectangle()
                            .frame(width: 30, height: 150)
                            .foregroundColor(.blue)
                        Rectangle()
                            .frame(width: 30, height: 80)
                            .foregroundColor(.gray.opacity(0.3))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
                .padding(.horizontal)
            }
            .padding(.bottom, 80)
        }
        .edgesIgnoringSafeArea(.top)
        .task {
            await authViewModel.fetchUser()
            if !isCheckingImage {
                isCheckingImage = true
                try? await AuthenticationManager.shared.checkAndUpdateProfileImage()
                isCheckingImage = false
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
