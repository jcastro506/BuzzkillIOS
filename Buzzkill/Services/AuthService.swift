import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol AuthServiceProtocol {
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func register(email: String, password: String, username: String, completion: @escaping (Result<User, Error>) -> Void)
    // Add other methods as needed
}

class AuthService: AuthServiceProtocol, ObservableObject {
    @Published var user: User?
    private let db = Firestore.firestore()

    init() {
        Auth.auth().addStateDidChangeListener { [weak self] auth, firebaseUser in
            if let firebaseUser = firebaseUser {
                // Fetch user data from Firestore
                self?.db.collection("users").document(firebaseUser.uid).getDocument { document, error in
                    if let document = document, document.exists {
                        let data = document.data() ?? [:]
                        let user = User(
                            id: firebaseUser.uid,
                            email: firebaseUser.email ?? "",
                            userName: firebaseUser.displayName ?? "",
                            createdAt: Date(timeIntervalSince1970: data["created_at"] as? TimeInterval ?? 0),
                            friends: data["friends"] as? [String] ?? [],
                            totalAmountSpent: data["total_amount_spent"] as? Double ?? 0.0,
                            totalBudgetsSet: data["total_budgets_set"] as? Int ?? 0,
                            pastBudgets: [] // Assuming you will fetch or handle past budgets separately
                        )
                        self?.user = user
                    } else {
                        self?.user = nil
                    }
                }
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
                // Fetch user data from Firestore
                self?.db.collection("users").document(firebaseUser.uid).getDocument { document, error in
                    if let document = document, document.exists {
                        let data = document.data() ?? [:]
                        let user = User(
                            id: firebaseUser.uid,
                            email: data["email"] as? String ?? "",
                            userName: data["user_name"] as? String ?? "",
                            createdAt: Date(timeIntervalSince1970: data["created_at"] as? TimeInterval ?? 0),
                            friends: data["friends"] as? [String] ?? [],
                            totalAmountSpent: data["total_amount_spent"] as? Double ?? 0.0,
                            totalBudgetsSet: data["total_budgets_set"] as? Int ?? 0,
                            pastBudgets: [] // Assuming you will fetch or handle past budgets separately;
                        )
                        self?.user = user
                        completion(.success(user))
                    } else {
                        print("User document does not exist")
                        completion(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data not found"])))
                    }
                }
            } else {
                let unknownError = NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown sign-in error"])
                print("Sign in failed with unknown error")
                completion(.failure(unknownError))
            }
        }
    }

    func register(email: String, password: String, username: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print("Registration failed with error: \(error.localizedDescription)")
                completion(.failure(error))
            } else if let firebaseUser = authResult?.user {
                // Map FirebaseAuth.User to your app's User model
                let user = User(
                    id: firebaseUser.uid,
                    email: firebaseUser.email ?? "",
                    userName: username,
                    createdAt: Date(),
                    friends: [],
                    totalAmountSpent: 0.0,
                    totalBudgetsSet: 0,
                    pastBudgets: []
                )
                
                // Add user to Firestore
                self?.db.collection("users").document(user.id).setData(user.toDictionary()) { error in
                    if let error = error {
                        print("Error adding user to Firestore: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        print("User successfully added to Firestore")
                        self?.user = user
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
