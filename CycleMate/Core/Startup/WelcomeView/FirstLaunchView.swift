import SwiftUI

struct FirstLaunchView: View {
    // Your properties remain the same
    @State private var currentPage = 0
    private let totalPages = 3
    @State private var animateContent = false
    @State private var isTransitioning = false
    
    // Your colors remain the same
    private let darkGray = Color(red: 31/255, green: 31/255, blue: 31/255)
    private let neonGreen = Color(red: 206/255, green: 253/255, blue: 0/255)
    
    // Your slides remain the same
    private let slides = [
        "Welcome to CycleMate!",
        "Track your cycling journey",
        "Let's get started!"
    ]
    
    var body: some View {
        VStack {
            // Your Spacer and main content remain the same
            Spacer()
            
            VStack(spacing: 30) {
                Text(slides[currentPage])
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(darkGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .offset(y: animateContent ? 0 : 50)
                    .opacity(animateContent ? 1 : 0)
            }
            
            Spacer()
            
            // Modified page indicators with slower animation
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Group {
                        if index == currentPage {
                            Capsule()
                                .fill(darkGray)
                                .frame(width: 16, height: 4)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 4, height: 4)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    // Slowed down animation
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
                }
            }
            .padding(.bottom, 10)
            
            // Modified navigation button with slower transition
            Button(action: {
                if currentPage < totalPages - 1 {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isTransitioning = true
                        animateContent = false
                        currentPage += 1
                        
                        // Increased delay for content animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            animateContent = true
                            isTransitioning = false
                        }
                    }
                }
            }) {
                // Your button content remains the same
                Text(currentPage == totalPages - 1 ? "Get Started" : "Next")
                    .font(.headline)
                    .foregroundColor(darkGray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(neonGreen)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .onAppear {
            animateContent = true
        }
    }
}

// Your preview remains the same
struct FirstLaunchView_Previews: PreviewProvider {
    static var previews: some View {
        FirstLaunchView()
    }
}

// End of file. No additional code.
