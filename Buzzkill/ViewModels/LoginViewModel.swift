import Foundation

class LoginViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    func login(email: String, password: String) {
        // Simulate authentication logic
        if !email.isEmpty && !password.isEmpty {
            // Simulate successful login
            isAuthenticated = true
            print("Login successful for email: \(email)")
        } else {
            // Simulate login failure
            isAuthenticated = false
            print("Login failed. Email or password is empty.")
        }
    }
} 