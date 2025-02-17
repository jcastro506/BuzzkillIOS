import SwiftUI

struct RootView: View {
    @State private var isUserNew = true // Assume a new user by default
    @State private var isUserSignedIn = false
    @State private var isOnboardingComplete = false
    @State private var isCardConnectionComplete = false // New state variable
    @EnvironmentObject var budgetModel: BudgetModel
    @State private var selectedTab = 0
    @State private var showSplashScreen = true // New state variable for splash screen

    var body: some View {
        Group {
            if showSplashScreen {
                SplashScreen()
                    .onAppear {
                        // Simulate a delay for the splash screen
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showSplashScreen = false
                        }
                    }
            } else if isUserSignedIn {
                MainTabView(selectedTab: $selectedTab)
            } else if isUserNew {
                SignUpView(isUserSignedIn: $isUserSignedIn, isNewUser: $isUserNew)
                    .onAppear {
                        print("Displaying SignUpView for new user")
                    }
            } else if !isOnboardingComplete {
                OnboardingView(isOnboardingComplete: $isOnboardingComplete)
                    .onAppear {
                        print("Displaying OnboardingView")
                    }
            } else if !isCardConnectionComplete { // Check if card connection is not complete
                ConnectCardView {
                    isCardConnectionComplete = true // Set to true when card connection is complete
                }
                .onAppear {
                    print("Displaying ConnectCardView")
                }
            } else {
                // LoginView(isLoginSuccessful: $isUserSignedIn)
                //     .onAppear {
                //         print("Displaying LoginView for existing user")
                //     }
                MainTabView(selectedTab: $selectedTab)
            }
        }
        .environmentObject(budgetModel)
        .preferredColorScheme(.dark)
    }
}

struct SplashScreenView: View {
    var body: some View {
        VStack {
            Text("Welcome to the App")
                .font(.largeTitle)
                .fontWeight(.bold)
            // Add any additional splash screen content here
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue)
        .foregroundColor(.white)
    }
} 
