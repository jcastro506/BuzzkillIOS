import Foundation
import Combine

protocol ProfileRepositoryProtocol {
    func fetchUserProfile(userId: String) async throws -> User
    func bindUserData(authService: AuthService) -> AnyPublisher<User, Never>
    // Add other methods as needed
}

class ProfileRepository: ProfileRepositoryProtocol {
    private let firestoreManager: FirestoreManager
    
    init(firestoreManager: FirestoreManager) {
        self.firestoreManager = firestoreManager
    }
    
    func fetchUserProfile(userId: String) async throws -> User {
        let data = try await firestoreManager.fetchDocument(collection: "users", documentId: userId)
        
        print("Raw document data: \(data)")
        do {
            let user = try self.mapDocumentToUser(data: data)
            return user
        } catch {
            throw error
        }
    }
    
    func bindUserData(authService: AuthService) -> AnyPublisher<User, Never> {
        return authService.$user
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    private func mapDocumentToUser(data: [String: Any]) throws -> User {
        guard let id = data["id"] as? String,
              let email = data["email"] as? String,
              let userName = data["user_name"] as? String,
              let createdAtTimestamp = data["created_at"] as? TimeInterval,
              let totalAmountSpent = data["total_amount_spent"] as? Double,
              let totalBudgetsSet = data["total_budgets_set"] as? Int else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid user data"])
        }
        
        let createdAt = Date(timeIntervalSince1970: createdAtTimestamp)
        print("Fetched user data: id=\(id), userName=\(userName), createdAt=\(createdAt)")
        
        let friends = data["friends"] as? [String] ?? []
        let pastBudgetsData = data["past_budgets"] as? [[String: Any]] ?? []
        let pastBudgets = try pastBudgetsData.map { try mapDocumentToPastBudget(data: $0) }
        
        return User(id: id, email: email, userName: userName, createdAt: createdAt, friends: friends, totalAmountSpent: totalAmountSpent, totalBudgetsSet: totalBudgetsSet, pastBudgets: pastBudgets)
    }
    
    private func mapDocumentToPastBudget(data: [String: Any]) throws -> PastBudget {
        // Implement mapping logic for PastBudget
        // This is a placeholder implementation
        if let idString = data["id"] as? String, let uuid = UUID(uuidString: idString) {
            let pastBudget = PastBudget(
                id: uuid,
                userId: "sampleUserId",
                totalAmount: 100.00,
                spentAmount: 80.00,
                name: "Sample Budget Name",
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
                isRecurring: false,
                status: "completed",
                transactions: [
                    Transaction(id: UUID(), amount: 20, date: Date(), description: "Sample Transaction", name: "Sample Name")
                ]
            )
            return pastBudget
        } else {
            print("Invalid UUID string")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid UUID format"])
        }
    }
} 