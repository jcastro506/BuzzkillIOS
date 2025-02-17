import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @ObservedObject var viewModel = LoginViewModel()
    @Binding var isLoginSuccessful: Bool
    @EnvironmentObject var authService: AuthService
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                // Logo
                Image(systemName: "lock.shield.fill") // Example system image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                // Title
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Input fields using CustomTextField
                CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $email)
                CustomTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                
                // Login Button
                Button(action: {
                    isLoading = true
                    authService.signIn(email: email, password: password) { result in
                        isLoading = false
                        switch result {
                        case .success:
                            isLoginSuccessful = true
                        case .failure(let error):
                            // Handle error (e.g., show an alert)
                            print("Login failed: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Login")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.cyan, Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
                        )
                }
                .padding(.top, 20)
                
                // Show ProgressView when loading
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.top, 10)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.gray]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            )
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    @State static var isLoginSuccessful = false
    
    static var previews: some View {
        LoginView(isLoginSuccessful: $isLoginSuccessful)
            .environmentObject(AuthService())
    }
} 