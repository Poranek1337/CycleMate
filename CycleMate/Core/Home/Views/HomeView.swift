//
//  HomeView.swift
//  CycleMate
//

import SwiftUI

struct HomeView: View {
    // Properties remain the same
    @EnvironmentObject private var authViewModel: AuthViewModel
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
                    
                    // Profile Picture Section
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
                
                // Components
                MapPreviewComponent()
                
                HStack(spacing: 15) {
                    BikesComponent()
                    StatsComponent()
                }
                .padding(.horizontal)
                
                MonthlyChartComponent()
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
