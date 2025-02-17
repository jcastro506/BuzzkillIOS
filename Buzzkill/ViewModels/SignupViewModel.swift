import Foundation

class SignupViewModel: ObservableObject {
    @Published var isRegistered: Bool = false
    
    func signUp(name: String, email: String, password: String) {
        // Simulate registration logic
        if !name.isEmpty && !email.isEmpty && !password.isEmpty {
            // Simulate successful registration
            isRegistered = true
            print("Registration successful for name: \(name), email: \(email)")
        } else {
            // Simulate registration failure
            isRegistered = false
            print("Registration failed. Name, email, or password is empty.")
        }
    }
} 