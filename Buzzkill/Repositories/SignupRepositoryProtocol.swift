import Foundation

protocol SignupRepositoryProtocol {
    func register(email: String, password: String, username: String, completion: @escaping (Result<Void, Error>) -> Void)
} 