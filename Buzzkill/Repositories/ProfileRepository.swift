import Foundation
import Combine
import FirebaseFirestore

protocol ProfileRepositoryProtocol {
    func fetchUserProfile(userId: String) async throws -> User
    func bindUserData(authService: AuthService) -> AnyPublisher<User, Never>
    // Add other methods as needed
}

class ProfileRepository: ProfileRepositoryProtocol {
    private let db = Firestore.firestore()
    
    func fetchUserProfile(userId: String) async throws -> User {
        let userRef = db.collection("users").document(userId)
        
        return try await withCheckedThrowingContinuation { continuation in
            userRef.getDocument { document, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let document = document, document.exists, let data = document.data() {
                    print("Raw document data: \(data)")
                    do {
                        let user = try self.mapDocumentToUser(data: data)
                        continuation.resume(returning: user)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                } else {
                    continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                }
            }
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
        return PastBudget(barName: "Example Bar", date: "Example Date", budget: Budget(id: UUID(), userId: "userId", totalAmount: 0, spentAmount: 0, name: "Example", startDate: Date(), endDate: Date(), isRecurring: false, status: "completed", transactions: []), transactions: [])
    }
} 