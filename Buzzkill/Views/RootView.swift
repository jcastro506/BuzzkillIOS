import SwiftUI
import FirebaseFirestore

struct RootView: View {
    @State private var isCardConnectionComplete = false
    @EnvironmentObject var budgetModel: BudgetModel
    @EnvironmentObject var authService: AuthService
    @State private var selectedTab = 0
    @State private var showSplashScreen = true

    var body: some View {
        Group {
            if showSplashScreen {
                SplashScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showSplashScreen = false
                        }
                    }
            } else if let user = authService.user {
                // User is signed in
                MainTabView(selectedTab: $selectedTab, authService: authService)
            } else {
                SignUpView(isUserSignedIn: .constant(false), isNewUser: .constant(true), signupRepository: SignupRepository())
                    .onAppear {
                        print("Displaying SignUpView for new user")
                    }
            }
        }
        .environmentObject(budgetModel)
        .environmentObject(authService)
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
