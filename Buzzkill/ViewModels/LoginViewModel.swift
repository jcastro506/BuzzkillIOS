import Foundation

class LoginViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    
    private var authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func login(email: String, password: String) {
        authService.signIn(email: email, password: password) { [weak self] result in
            switch result {
            case .success:
                self?.isAuthenticated = true
                self?.errorMessage = nil
            case .failure(let error):
                self?.isAuthenticated = false
                self?.errorMessage = error.localizedDescription
            }
        }
    }
} 