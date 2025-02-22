import Foundation

protocol PastBudgetsRepositoryProtocol {
    func fetchPastBudgets(page: Int, size: Int, completion: @escaping ([PastBudget]) -> Void)
} 