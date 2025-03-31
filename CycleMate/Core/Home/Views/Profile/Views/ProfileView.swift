//
//  ProfileView.swift
//  CycleMate
//
//  Created by Poranek on 29/03/2025.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ProfileHeader()
                    
                    VStack(spacing: 25) {
                        MembershipCardView()
                        
                        StatsGridView()
                        
                        ActivitySummaryView()
                        
                        SavedRoutesView()
                    }
                    .padding(.horizontal)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
