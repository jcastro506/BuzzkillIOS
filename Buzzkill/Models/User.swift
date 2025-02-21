import Foundation

struct User {
    var id: UUID
    var email: String
    var userName: String
    var createdAt: Date
    var friends: [String] // Assuming friends are stored as an array of user IDs or names
    var totalAmountSpent: Double
    var totalBudgetsSet: Int
    var pastBudgets: [PastBudget] // Add this line to include a list of past budgets
    // Add other user properties here

    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "email": email,
            "user_name": userName,
            "created_at": createdAt.timeIntervalSince1970, // Convert Date to timestamp
            "friends": friends,
            "total_amount_spent": totalAmountSpent,
            "total_budgets_set": totalBudgetsSet,
            "past_budgets": pastBudgets.map { $0.toDictionary() }, // Convert budgets to dictionary if needed
            // Add other properties here
        ]
    }
} 