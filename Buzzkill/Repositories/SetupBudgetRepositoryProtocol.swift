import Foundation

protocol SetupBudgetRepositoryProtocol {
    func saveBudgetToFirestore(budget: Budget, completion: @escaping (Error?) -> Void)
    func checkForActiveBudget(userId: String, completion: @escaping (Bool, Error?) -> Void)
    func cancelActiveBudget(userId: String, completion: @escaping (Error?) -> Void)
    func addPastBudgetToUser(userId: String, pastBudget: PastBudget, completion: @escaping (Error?) -> Void)
} 