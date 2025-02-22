import Foundation

protocol AuthRepositoryProtocol {
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
}

class AuthRepository: AuthRepositoryProtocol {
    static let shared = AuthRepository()
    
    private init() {}
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Simulate an authentication process
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            if email == "test@example.com" && password == "password" {
                completion(.success(()))
            } else {
                let error = NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])
                completion(.failure(error))
            }
        }
    }
} 