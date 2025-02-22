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
        
        return (0..<size).map { index in
            PastBudget(
                barName: barNames[(page * size + index) % barNames.count],
                date: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none),
                budget: Budget(
                    id: UUID(),
                    userId: "sampleUserId",
                    totalAmount: Double.random(in: 500...1000),
                    spentAmount: Double.random(in: 50...500),
                    name: barNames[(page * size + index) % barNames.count],
                    startDate: Date(),
                    endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
                    isRecurring: false,
                    status: "completed",
                    transactions: generateDummyTransactions()
                ),
                transactions: generateDummyTransactions()
            )
        }
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