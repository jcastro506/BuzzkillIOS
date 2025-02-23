import Foundation
import FirebaseFirestore

protocol PastBudgetsRepositoryProtocol {
    func fetchUserPastBudgets(userId: String, completion: @escaping ([PastBudget]?, Error?) -> Void)
    func fetchPastBudgets(lastDocument: DocumentSnapshot?, size: Int, completion: @escaping ([PastBudget], DocumentSnapshot?) -> Void)
} 