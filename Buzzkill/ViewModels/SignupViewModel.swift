import Foundation
import Firebase
import Combine

class SignUpViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var isRegistered: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isNewUser: Bool = false
    
    private var signupRepository: SignupRepositoryProtocol
    
    init(signupRepository: SignupRepositoryProtocol) {
        self.signupRepository = signupRepository
    }
    
    func signUp() {
        guard validateInputs() else {
            return
        }
        
        isLoading = true
        signupRepository.register(email: email, password: password, username: username) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.isRegistered = true
                    self?.isNewUser = true
                    self?.errorMessage = nil
                    print("Registration successful for name: \(self?.username ?? ""), email: \(self?.email ?? "")")
                case .failure(let error):
                    self?.isRegistered = false
                    self?.errorMessage = error.localizedDescription
                    print("Registration failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func validateInputs() -> Bool {
        if username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            errorMessage = "All fields are required."
            return false
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords do not match."
            return false
        }
        
        if !isValidEmail(email) {
            errorMessage = "Invalid email format."
            return false
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters long."
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        // Simple regex for email validation
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
} 