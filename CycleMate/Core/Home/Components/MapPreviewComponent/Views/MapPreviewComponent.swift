//
//  MapPreviewComponent.swift
//  CycleMate
//
//  Created by Poranek on 11/01/2025.
//

import SwiftUI
import CoreLocation

struct MapPreviewComponent: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        ZStack {
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
        }
        .padding(.horizontal)
    }
}

#Preview {
    MapPreviewComponent()
}
