import SwiftUI

struct SplashScreen: View {
    @State private var isAnimating = false
    @State private var opacity: Double = 0.3

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                Image(systemName: "flame.fill") // Change to a custom aggressive icon if needed
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.red)
                    .opacity(isAnimating ? 1 : 0.5)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                
                Text("BUZZKILL")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.red)
                    .shadow(color: .red.opacity(0.8), radius: 10, x: 0, y: 0)
                    .opacity(opacity)
                    .animation(Animation.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: opacity)
            }
            .onAppear {
                isAnimating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    // Transition to OnboardingView
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
}