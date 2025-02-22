import Foundation
import FirebaseFirestore

class SetupBudgetRepository: SetupBudgetRepositoryProtocol {
    private let db = Firestore.firestore()

    func saveBudgetToFirestore(budget: Budget, completion: @escaping (Error?) -> Void) {
        db.collection("budgets").document(budget.id.uuidString).setData(budget.toDictionary()) { error in
            completion(error)
        }
    }

    func checkForActiveBudget(userId: String, completion: @escaping (Bool, Error?) -> Void) {
        db.collection("budgets")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "active")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(false, error)
                } else {
                    completion(querySnapshot?.documents.isEmpty == false, nil)
                }
            }
    }

    func cancelActiveBudget(userId: String, completion: @escaping (Error?) -> Void) {
        db.collection("budgets")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "active")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(error)
                } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                    for document in documents {
                        document.reference.updateData(["status": "cancelled"]) { error in
                            if let error = error {
                                completion(error)
                            } else {
                                completion(nil)
                            }
                        }
                    }
                } else {
                    completion(nil)
                }
            }
    }

    func addPastBudgetToUser(userId: String, pastBudget: PastBudget, completion: @escaping (Error?) -> Void) {
        let userRef = db.collection("users").document(userId)
        userRef.updateData([
            "pastBudgets": FieldValue.arrayUnion([pastBudget.toDictionary()])
        ]) { error in
            completion(error)
        }
    }
} 