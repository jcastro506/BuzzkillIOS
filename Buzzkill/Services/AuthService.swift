import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol AuthServiceProtocol {
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func register(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    // Add other methods as needed
}

class AuthService: AuthServiceProtocol, ObservableObject {
    @Published var user: User?
    private let db = Firestore.firestore()

    init() {
        Auth.auth().addStateDidChangeListener { [weak self] auth, firebaseUser in
            if let firebaseUser = firebaseUser {
                // Map FirebaseAuth.User to your app's User model
                let user = User(
                    id: UUID(),
                    email: firebaseUser.email ?? "",
                    userName: firebaseUser.displayName ?? "",
                    createdAt: Date(), // Assuming current date for new users
                    friends: [], // Assuming empty list for new users
                    totalAmountSpent: 0.0, // Assuming 0 for new users
                    totalBudgetsSet: 0, // Assuming 0 for new users
                    pastBudgets: [] // Initialize with an empty list of past budgets
                )
                self?.user = user
                // Call Firestore function here
            } else {
                self?.user = nil
            }
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print("Sign in failed with error: \(error.localizedDescription)")
                completion(.failure(error))
            } else if let firebaseUser = authResult?.user {
                // Map FirebaseAuth.User to your app's User model
                let user = User(
                    id: UUID(),
                    email: firebaseUser.email ?? "",
                    userName: firebaseUser.displayName ?? "",
                    createdAt: Date(), // Assuming current date for new users
                    friends: [], // Assuming empty list for new users
                    totalAmountSpent: 0.0, // Assuming 0 for new users
                    totalBudgetsSet: 0, // Assuming 0 for new users
                    pastBudgets: [] // Initialize with an empty list of past budgets
                )
                completion(.success(user))
                // Call Firestore function here
            } else {
                let unknownError = NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown sign-in error"])
                print("Sign in failed with unknown error")
                completion(.failure(unknownError))
            }
        }
    }

    func register(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print("Registration failed with error: \(error.localizedDescription)")
                completion(.failure(error))
            } else if let firebaseUser = authResult?.user {
                // Map FirebaseAuth.User to your app's User model
                let user = User(
                    id: UUID(),
                    email: firebaseUser.email ?? "",
                    userName: firebaseUser.displayName ?? "",
                    createdAt: Date(), // Assuming current date for new users
                    friends: [], // Assuming empty list for new users
                    totalAmountSpent: 0.0, // Assuming 0 for new users
                    totalBudgetsSet: 0, // Assuming 0 for new users
                    pastBudgets: [] // Initialize with an empty list of past budgets
                )
                
                // Add user to Firestore
                self?.db.collection("users").document(user.id.uuidString).setData(user.toDictionary()) { error in
                    if let error = error {
                        print("Error adding user to Firestore: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("User successfully added to Firestore")
                        completion(.success(user))
                    }
                }
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
