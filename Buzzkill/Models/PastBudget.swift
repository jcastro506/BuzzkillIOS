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
} 
