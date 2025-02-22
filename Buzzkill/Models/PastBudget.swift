import Foundation

struct PastBudget: Identifiable {
    let id = UUID()
    let barName: String
    let date: String
    let budget: Budget
    let transactions: [Transaction] // Ensure this is part of the model

    var isUnderBudget: Bool {
        return budget.spentAmount <= budget.totalAmount
    }
    
    var overspentAmount: Double {
        return max(0, budget.spentAmount - budget.totalAmount)
    }
    
    var underspentAmount: Double {
        return max(0, budget.totalAmount - budget.spentAmount)
    }
    
    // Update this method to convert PastBudget to a dictionary
    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "barName": barName,
            "date": date,
            "budget": budget.toDictionary(),
            "transactions": transactions.map { $0.toDictionary() } // Assuming Transaction has a toDictionary method
        ]
    }
} 
