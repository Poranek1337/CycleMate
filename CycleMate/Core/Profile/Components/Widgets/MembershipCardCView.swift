//
//  MembershipCardCView.swift
//  CycleMate
//
//  Created by Poranek on 30/03/2025.
//

import SwiftUI

struct MembershipCardView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Member Since")
                    .font(.subheadline)
                    .foregroundColor(.gray)
//                if let user = authViewModel.currentUser {
                    Text("60 days")
                        .font(.title2)
                        .bold()
                    
                    Text("2025")
                        .font(.caption)
                        .foregroundColor(.gray)
//                }
            }
            
            Spacer()
            
            Image(systemName: "crown.fill")
                .font(.system(size: 40))
                .foregroundColor(.yellow)
                .shadow(color: .orange.opacity(0.3), radius: 5, x: 0, y: 2)
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    MembershipCardView()
}
