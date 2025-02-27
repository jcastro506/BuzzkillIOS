import Foundation
import FirebaseFirestore

class HomeRepository {
    // Singleton instance
    static let shared = HomeRepository()
    
    private let db = Firestore.firestore()
    
    private init() {
        // Private initializer to ensure only one instance is created
    }
    
    // Example method to fetch home data
    func fetchHomeData(completion: @escaping (Result<[String], Error>) -> Void) {
        // Simulate fetching data
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            // Simulate success with dummy data
            let homeData = ["Home Item 1", "Home Item 2", "Home Item 3"]
            completion(.success(homeData))
        }
    }
    
    // Example method to update home data
    func updateHomeData(_ data: [String], completion: @escaping (Bool) -> Void) {
        // Simulate updating data
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            // Simulate success
            completion(true)
        }
    }
    
    // New method to add a transaction
    func addTransaction(amount: Double, currentAmountSpent: Double, totalBudget: Double, completion: @escaping (Double) -> Void) {
        let newAmountSpent = currentAmountSpent + amount
        completion(newAmountSpent)
    }
    
    // New method to update live activity
    func updateLiveActivity(with newAmountSpent: Double, totalBudget: Double, completion: @escaping (BudgetDetailsWidgetAttributes.ContentState) -> Void) {
        let amountRemaining = totalBudget - newAmountSpent
        
        let updatedContentState = BudgetDetailsWidgetAttributes.ContentState(
            totalBudget: totalBudget,
            amountSpent: newAmountSpent,
            amountRemaining: amountRemaining
        )
        
        completion(updatedContentState)
    }
    
    // Updated method to fetch current budget from Firestore
    func fetchCurrentBudget(userId: String, completion: @escaping (Double?, Error?) -> Void) {
        let budgetsRef = FirestoreManager.shared.db.collection("budgets").whereField("userId", isEqualTo: userId).whereField("status", isEqualTo: "active")
        
        budgetsRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching current budget: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let documents = querySnapshot?.documents, !documents.isEmpty {
                if let currentBudget = documents.first?.data()["totalAmount"] as? Double {
                    print("Current Budget: \(currentBudget)")
                    completion(currentBudget, nil)
                } else {
                    print("Current budget not found in documents")
                    completion(nil, nil)
                }
            } else {
                print("No active budget found for userId: \(userId)")
                completion(nil, nil)
            }
        }
    }
    
    // Add this method to check for an active budget
    func checkForActiveBudget(userId: String, completion: @escaping (Bool, Error?) -> Void) {
        db.collection("budgets")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "active")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(false, error)
                } else {
                    let hasActiveBudget = querySnapshot?.documents.isEmpty == false
                    completion(hasActiveBudget, nil)
                }
            }
    }
    
    // New method to fetch past budgets for a user
    func fetchPastBudgets(userId: String, completion: @escaping ([PastBudget]?, Error?) -> Void) {
        let pastBudgetsRef = FirestoreManager.shared.db.collection("past_budgets").whereField("userId", isEqualTo: userId)
        
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
} 