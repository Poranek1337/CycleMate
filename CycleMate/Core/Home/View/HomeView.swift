//
//  HomeView.swift
//  CycleMate
//

import SwiftUI

struct HomeView: View {
    // Add AuthViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    
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
                    
                    // Profile Picture
                    if let photoURL = authViewModel.currentUser?.photoURL, !photoURL.isEmpty {
                        AsyncImage(url: URL(string: photoURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } placeholder: {
                            Circle()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        }
                    } else {
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
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
        }
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
