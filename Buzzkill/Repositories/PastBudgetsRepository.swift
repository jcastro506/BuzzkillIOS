import Foundation
import FirebaseFirestore

class PastBudgetsRepository: PastBudgetsRepositoryProtocol {
    
    static let shared = PastBudgetsRepository()

    private let db = FirestoreManager.shared.db

    func fetchPastBudgets(lastDocument: DocumentSnapshot?, size: Int, completion: @escaping ([PastBudget], DocumentSnapshot?) -> Void) {
        var query: Query = db.collection("past_budgets")
            .order(by: "startDate", descending: true)
            .limit(to: size)

        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }

        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching past budgets: \(error.localizedDescription)")
                completion([], nil)
                return
            }
            
            if let documents = querySnapshot?.documents {
                let pastBudgets = documents.compactMap { document -> PastBudget? in
                    let data = document.data()
                    return PastBudget.fromDictionary(data)
                }
                let lastDocument = documents.last
                completion(pastBudgets, lastDocument)
            } else {
                print("No past budgets found")
                completion([], nil)
            }
        }
    }

    func fetchUserPastBudgets(userId: String, completion: @escaping ([PastBudget]?, Error?) -> Void) {
        let pastBudgetsRef = db.collection("past_budgets").whereField("userId", isEqualTo: userId)
        
        pastBudgetsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching past budgets: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let documents = querySnapshot?.documents {
                let pastBudgets = documents.compactMap { document -> PastBudget? in
                    let data = document.data()
                    return PastBudget.fromDictionary(data)
                }
                completion(pastBudgets, nil)
            } else {
                print("No past budgets found for userId: \(userId)")
                completion([], nil)
            }
        }
    }

    // Implement other methods required by the protocol
} 
