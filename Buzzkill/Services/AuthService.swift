import Foundation
import FirebaseAuth

protocol AuthServiceProtocol {
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    // Add other methods as needed
}

class AuthService: AuthServiceProtocol, ObservableObject {
    @Published var user: User?

    init() {
        Auth.auth().addStateDidChangeListener { auth, firebaseUser in
            if let firebaseUser = firebaseUser {
                // Map FirebaseAuth.User to your app's User model
                self.user = User(id: UUID(), name: firebaseUser.displayName ?? "", email: firebaseUser.email ?? "")
            } else {
                self.user = nil
            }
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Sign in failed with error: \(error.localizedDescription)")
                completion(.failure(error))
            } else if let firebaseUser = authResult?.user {
                // Map FirebaseAuth.User to your app's User model
                let user = User(id: UUID(), name: firebaseUser.displayName ?? "", email: firebaseUser.email ?? "")
                completion(.success(user))
            } else {
                let unknownError = NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown sign-in error"])
                print("Sign in failed with unknown error")
                completion(.failure(unknownError))
            }
        }
    }

    func register(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Registration failed with error: \(error.localizedDescription)")
                completion(.failure(error))
            } else if let firebaseUser = authResult?.user {
                // Map FirebaseAuth.User to your app's User model
                let user = User(id: UUID(), name: firebaseUser.displayName ?? "", email: firebaseUser.email ?? "")
                completion(.success(user))
            } else {
                let unknownError = NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown registration error"])
                print("Registration failed with unknown error")
                completion(.failure(unknownError))
            }
        }
    }

    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Sign out failed with error: \(signOutError.localizedDescription)")
            throw signOutError
        }
    }
} 