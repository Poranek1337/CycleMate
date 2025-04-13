//
//  HomeView.swift
//  CycleMate
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var isCheckingImage = false
    @State private var showProfileView = false

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
                    
                    Button {
                        showProfileView = true
                    } label: {
                        ProfileImageView(user: authViewModel.currentUser, size: 50)
                    }
                }
                .padding()
                
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
        .sheet(isPresented: $showProfileView) {
            ProfileView()
        }
        .task {
            // Sprawdź czy sesja jest aktualna
            await authViewModel.checkSession()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
