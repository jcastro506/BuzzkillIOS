import SwiftUI
import ActivityKit

class HomeViewViewModel: ObservableObject {
    @Published var spent: Double = 0.0
    @Published var transactions: [Transaction] = []
    @Published var selectedTransaction: Transaction?
    @Published var showEditSheet = false
    @Published var selectedPastBudget: PastBudget?
    @Published var showBudgetDetailModal = false
    
    var budgetModel: BudgetModel

    init(budgetModel: BudgetModel) {
        self.budgetModel = budgetModel
        updateSpentAmount()
        let newBudgetAmount = UserDefaults.standard.double(forKey: "userBudget")
        if budgetModel.budgetAmount != newBudgetAmount {
            budgetModel.budgetAmount = newBudgetAmount
        }
    }

    func addDummyTransaction() {
        let dummyTransaction = Transaction(
            id: UUID(),
            amount: 10.0, // Dummy amount
            date: Date(),
            description: "Dummy Transaction",
            name: "Test"
        )
        transactions.append(dummyTransaction)
        updateSpentAmount()
        
        // Update the Live Activity
        addTransaction(amount: 10.0, currentAmountSpent: spent, totalBudget: budgetModel.budgetAmount)
    }
    
    func updateSpentAmount() {
        spent = transactions.reduce(0) { $0 + $1.amount }
    }
    
    private func addTransaction(amount: Double, currentAmountSpent: Double, totalBudget: Double) {
        let newAmountSpent = currentAmountSpent + amount
        updateLiveActivity(with: newAmountSpent, totalBudget: totalBudget)
    }
    
    private func updateLiveActivity(with newAmountSpent: Double, totalBudget: Double) {
        let amountRemaining = totalBudget - newAmountSpent
        
        let updatedContentState = BudgetDetailsWidgetAttributes.ContentState(
            totalBudget: totalBudget,
            amountSpent: newAmountSpent,
            amountRemaining: amountRemaining
        )
        
        if let activity = Activity<BudgetDetailsWidgetAttributes>.activities.first {
            Task {
                await activity.update(using: updatedContentState)
            }
        }
    }
} 