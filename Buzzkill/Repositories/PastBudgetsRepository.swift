import Foundation

class PastBudgetsRepository: PastBudgetsRepositoryProtocol {
    static let shared = PastBudgetsRepository()

    func fetchPastBudgets(page: Int, size: Int, completion: @escaping ([PastBudget]) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let budgets = self.generateDummyBudgets(page: page, size: size)
            completion(budgets)
        }
    }

    private func generateDummyBudgets(page: Int, size: Int) -> [PastBudget] {
        let barNames = [
            "The Tipsy Tavern", "Neon Nights", "The Rusty Nail", 
            "Moonlight Lounge", "The Happy Hour", "The Drunken Duck", 
            "The Buzz Bar", "The Liquid Lounge", "The Velvet Room", 
            "The Whiskey Way"
        ]
        
        var budgets: [PastBudget] = []
        
        for index in 0..<size {
            let barName = barNames[(page * size + index) % barNames.count]
            let totalAmount = Double.random(in: 500...1000)
            let spentAmount = Double.random(in: 50...500)
            let transactions = generateDummyTransactions()
            
            let budget = PastBudget(
                id: UUID(),
                userId: "sampleUserId",
                totalAmount: totalAmount,
                spentAmount: spentAmount,
                name: barName,
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
                isRecurring: false,
                status: "completed",
                transactions: transactions
            )
            
            budgets.append(budget)
        }
        
        return budgets
    }

    private func generateDummyTransactions() -> [Transaction] {
        return (0..<5).map { index in
            Transaction(
                id: UUID(),
                amount: Double.random(in: 10...100),
                date: Date(),
                description: "Transaction \(index + 1)",
                name: "Transaction Name \(index + 1)"
            )
        }
    }
} 