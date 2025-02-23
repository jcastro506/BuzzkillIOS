import Foundation
import Firebase
import FirebaseAuth

class SignupRepository: SignupRepositoryProtocol {
    private let firestoreManager: FirestoreManager

    init(firestoreManager: FirestoreManager) {
        self.firestoreManager = firestoreManager
    }

    func register(email: String, password: String, username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Assuming Firebase Auth is used for registration
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Optionally, update the user's profile with the username
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        // Call the new function to add the user to Firestore
                        self.addUserToFirestore(email: email, username: username, completion: completion)
                    }
                }
            }
        }
    }
    
    private func addUserToFirestore(email: String, username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "SignupRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not found"])))
            return
        }
        
        // Create a User instance with default values
        let user = User(
            id: userId,
            email: email,
            userName: username,
            createdAt: Date(),
            friends: [],
            totalAmountSpent: 0.0,
            totalBudgetsSet: 0,
            pastBudgets: [],
            currentBudget: nil // Initialize with nil or a default Budget
        )
        
        // Use FirestoreManager to set data
        firestoreManager.saveDocument(collection: "users", documentId: userId, data: user.toDictionary()) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
} 