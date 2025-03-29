import SwiftUI
import CoreLocation

struct SpeedometerView: View {
    @ObservedObject var locationManager: LocationManager
    
    private var speed: Double {
        guard let location = locationManager.lastLocation else { return 0 }
        let speedInKmh = location.speed * 3.6 // Convert m/s to km/h
        return max(0, speedInKmh) // Ensure non-negative speed
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Speed display
            VStack {
                Text(String(format: "%.1f", speed))
                    .font(.system(size: 80, weight: .bold))
                    .monospacedDigit()
                Text("km/h")
                    .font(.title2)
            }
            
            // Trip info
            HStack(spacing: 40) {
                VStack {
                    Text("Distance")
                        .font(.headline)
                    Text("0.0 km")
                        .font(.title3)
                }
                
                VStack {
                    Text("Time")
                        .font(.headline)
                    Text("00:00")
                        .font(.title3)
                }
            }
            
            // Average speed
            VStack {
                Text("Average Speed")
                    .font(.headline)
                Text("0.0 km/h")
                    .font(.title3)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}

