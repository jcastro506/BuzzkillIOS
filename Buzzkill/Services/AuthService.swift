import Foundation
import FirebaseAuth

class AuthService: ObservableObject {
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
                completion(.failure(error))
            } else if let firebaseUser = authResult?.user {
                // Map FirebaseAuth.User to your app's User model
                let user = User(id: UUID(), name: firebaseUser.displayName ?? "", email: firebaseUser.email ?? "")
                completion(.success(user))
            }
        }
    }

    func register(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let firebaseUser = authResult?.user {
                // Map FirebaseAuth.User to your app's User model
                let user = User(id: UUID(), name: firebaseUser.displayName ?? "", email: firebaseUser.email ?? "")
                completion(.success(user))
            }
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
} 