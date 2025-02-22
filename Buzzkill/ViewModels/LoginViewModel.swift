import Foundation

class LoginViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    
    private var authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol = AuthRepository.shared) {
        self.authRepository = authRepository
    }
    
    func login(email: String, password: String) {
        authRepository.signIn(email: email, password: password) { [weak self] result in
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