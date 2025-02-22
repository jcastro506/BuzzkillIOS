import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SignupRepository: SignupRepositoryProtocol {
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
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        userRef.setData([
            "email": email,
            "user_name": username,
            "created_at": Date().timeIntervalSince1970
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
} 