import SwiftUI
import ActivityKit
import Combine

class HomeViewViewModel: ObservableObject {
    @Published var spent: Double = 0.0
    @Published var transactions: [Transaction] = []
    @Published var selectedTransaction: Transaction?
    @Published var showEditSheet = false
    @Published var selectedPastBudget: PastBudget?
    @Published var showBudgetDetailModal = false
    @Published var hasActiveBudget: Bool = true
    
    var budgetModel: BudgetModel
    private let homeRepository = HomeRepository.shared
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()

    init(budgetModel: BudgetModel, authService: AuthService) {
        self.budgetModel = budgetModel
        self.authService = authService
        updateSpentAmount()
        
        // Ensure the budget is fetched after the user is set
        authService.onUserSet { [weak self] in
            self?.fetchAndUpdateCurrentBudget()
        }
        
        // Listen for budget updates
        let setupBudgetViewModel = SetupBudgetViewModel(budgetModel: budgetModel, userId: authService.user?.id ?? "")
        setupBudgetViewModel.budgetUpdated
            .sink { [weak self] in
                self?.fetchAndUpdateCurrentBudget()
            }
            .store(in: &cancellables)
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
        
        // Use HomeRepository to add transaction
        homeRepository.addTransaction(amount: 10.0, currentAmountSpent: spent, totalBudget: budgetModel.budgetAmount) { newAmountSpent in
            self.updateLiveActivity(with: newAmountSpent, totalBudget: self.budgetModel.budgetAmount)
        }
    }
    
    func updateSpentAmount() {
        spent = transactions.reduce(0) { $0 + $1.amount }
    }
    
    private func updateLiveActivity(with newAmountSpent: Double, totalBudget: Double) {
        homeRepository.updateLiveActivity(with: newAmountSpent, totalBudget: totalBudget) { updatedContentState in
            if let activity = Activity<BudgetDetailsWidgetAttributes>.activities.first {
                Task {
                    await activity.update(using: updatedContentState)
                }
            }
        }
    }

    func fetchAndUpdateCurrentBudget() {
        guard let userId = authService.user?.id else {
            print("User ID not available")
            return
        }
        
        print("Fetching current budget for user ID: \(userId)")
        
        homeRepository.fetchCurrentBudget(userId: userId) { [weak self] currentBudget, error in
            if let error = error {
                print("Failed to fetch current budget: \(error.localizedDescription)")
                return
            }
            
            if let currentBudget = currentBudget {
                DispatchQueue.main.async {
                    self?.budgetModel.budgetAmount = currentBudget
                    self?.updateSpentAmount() // Ensure spent amount is recalculated
                    print("Current budget updated: \(currentBudget)")
                }
            } else {
                print("Current budget is nil, check Firestore data mapping")
            }
        }
        
        // Fetch the current budget and update the hasActiveBudget property
        // This is a placeholder for the actual implementation
        homeRepository.checkForActiveBudget(userId: userId) { [weak self] hasActiveBudget, error in
            if let error = error {
                print("Error checking for active budget: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self?.hasActiveBudget = hasActiveBudget
            }
        }
    }
} 
