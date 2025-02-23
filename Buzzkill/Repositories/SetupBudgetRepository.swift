import Foundation
import FirebaseFirestore

class SetupBudgetRepository: SetupBudgetRepositoryProtocol {
    private let firestoreManager: FirestoreManager

    init(firestoreManager: FirestoreManager) {
        self.firestoreManager = firestoreManager
    }

    func saveBudgetToFirestore(budget: Budget, completion: @escaping (Error?) -> Void) {
        firestoreManager.saveDocument(collection: "budgets", documentId: budget.id.uuidString, data: budget.toDictionary(), completion: completion)
    }

    func checkForActiveBudget(userId: String, completion: @escaping (Bool, Error?) -> Void) {
        firestoreManager.fetchDocuments(collection: "budgets", filters: [("userId", userId), ("status", "active")]) { [weak self] querySnapshot, error in
            guard let self = self else { return }
            if let error = error {
                completion(false, error)
            } else {
                completion(querySnapshot?.documents.isEmpty == false, nil)
            }
        }
    }

    func cancelActiveBudget(userId: String, completion: @escaping (Error?) -> Void) {
        firestoreManager.fetchDocuments(collection: "budgets", filters: [("userId", userId), ("status", "active")]) { [weak self] querySnapshot, error in
            guard let self = self else { return }
            if let error = error {
                completion(error)
            } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                for document in documents {
                    self.firestoreManager.updateDocument(collection: "budgets", documentId: document.documentID, data: ["status": "cancelled"], completion: completion)
                }
            } else {
                completion(nil)
            }
        }
    }

    func addPastBudgetToUser(userId: String, pastBudget: PastBudget, completion: @escaping (Error?) -> Void) {
        firestoreManager.updateDocument(collection: "users", documentId: userId, data: [
            "pastBudgets": FieldValue.arrayUnion([pastBudget.toDictionary()])
        ], completion: completion)
    }

    func updateBudgetStatus(userId: String, status: String) {
        let db = Firestore.firestore()
        let budgetsRef = db.collection("budgets").whereField("userId", isEqualTo: userId).whereField("status", isEqualTo: "active")
        
        budgetsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching active budgets: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.updateData(["status": status]) { error in
                        if let error = error {
                            print("Error updating budget status: \(error)")
                        } else {
                            print("Budget status successfully updated to \(status)")
                        }
                    }
                }
            }
        }
    }
} 