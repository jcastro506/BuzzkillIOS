import Foundation

struct PastBudget: Identifiable {
    let id = UUID()
    let barName: String
    let date: String
    let amountSpent: Double
    let budget: Double
    let transactions: [Transaction] // Ensure this is part of the model

    var isUnderBudget: Bool {
        return amountSpent <= budget
    }
    
    var overspentAmount: Double {
        return max(0, amountSpent - budget)
    }
    
    var underspentAmount: Double {
        return max(0, budget - amountSpent)
    }
    
    // Add this method to convert PastBudget to a dictionary
    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "barName": barName,
            "date": date,
            "amountSpent": amountSpent,
            "budget": budget,
            "transactions": transactions.map { $0.toDictionary() } // Assuming Transaction has a toDictionary method
        ]
    }
} 
