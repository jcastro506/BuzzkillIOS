import Foundation
import SwiftUI
import CoreLocation
import ActivityKit
import FirebaseFirestore
import Combine
import Firebase

class SetupBudgetViewModel: ObservableObject {
    @Published var budgetAmount: String = "50"
    @Published var overBudgetAlert: Bool = false
    @Published var autoStartBudget: Bool = false
    @Published var showAutoStartPrompt: Bool = false
    @Published var showInfoAlert: Bool = false
    @Published var infoMessage: String = ""
    @Published var showConfirmationAlert: Bool = false
    @Published var showActiveBudgetAlert: Bool = false
    
    var locationManager = LocationManager()
    private var budgetModel: BudgetModel
    private var userId: String
    private let db = Firestore.firestore()
    private let setupBudgetRepository: SetupBudgetRepository
    var budgetUpdated = PassthroughSubject<Void, Never>()

    init(budgetModel: BudgetModel, userId: String, firestoreManager: FirestoreManager = FirestoreManager.shared) {
        self.budgetModel = budgetModel
        self.userId = userId
        self.setupBudgetRepository = SetupBudgetRepository(firestoreManager: firestoreManager)
    }

    func adjustBudget(by amount: Int) {
        if let currentAmount = Double(budgetAmount) {
            budgetAmount = String(Int(currentAmount) + amount)
        }
    }

    func selectPresetBudget(amount: Int) {
        budgetAmount = String(amount)
    }

    func toggleAutoStartBudget() {
        if autoStartBudget {
            showAutoStartPrompt = true
            locationManager.requestPermission()
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
        }
    }

    func lockInBudget(authService: AuthService) {
        guard let user = authService.user else { return }
        
        setupBudgetRepository.checkForActiveBudget(userId: user.id) { [weak self] hasActiveBudget, error in
            if let error = error {
                print("Error checking for active budget: \(error.localizedDescription)")
                return
            }
            
            if hasActiveBudget {
                DispatchQueue.main.async {
                    self?.showActiveBudgetAlert = true
                }
                print("User \(user.id) already has an active budget.")
            } else if let amount = Double(self?.budgetAmount ?? "0") {
                let budget = Budget(
                    id: UUID(),
                    userId: user.id,
                    totalAmount: amount,
                    spentAmount: 0.0,
                    name: "New Budget",
                    startDate: Date(),
                    endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
                    isRecurring: false,
                    status: "active",
                    transactions: []
                )
                
                print("Creating new budget for user \(user.id): \(budget)")
                self?.saveBudget(budget: budget, authService: authService)
            }
        }
    }

    private func saveBudget(budget: Budget, authService: AuthService) {
        setupBudgetRepository.saveBudgetToFirestore(budget: budget) { [weak self] error in
            if let error = error {
                print("Error saving budget: \(error.localizedDescription)")
            } else {
                // Update the local user object
                authService.user?.currentBudget = budget
                
                // Notify that the budget has been updated
                self?.budgetUpdated.send()
                
                // Update Firestore
                let userRef = self?.db.collection("users").document(budget.userId)
                userRef?.updateData([
                    "current_budget": budget.toDictionary()
                ]) { error in
                    if let error = error {
                        print("Error updating Firestore: \(error.localizedDescription)")
                    } else {
                        self?.showConfirmationAlert = true
                    }
                }
            }
        }
    }

    func cancelActiveBudget(authService: AuthService) {
        guard let userId = authService.user?.id else { return }
        
        setupBudgetRepository.updateBudgetStatus(userId: userId, status: "inactive") { [weak self] (error: Error?) in
            if let error = error {
                print("Error updating budget status: \(error.localizedDescription)")
                return
            }
            
            // Retrieve the current budget before deleting it
            guard let currentBudget = authService.user?.currentBudget else {
                print("No current budget found for user.")
                return
            }
            
            // Delete the currentBudget from the user in Firestore
            self?.setupBudgetRepository.deleteCurrentBudgetFromUser(userId: userId) { (error: Error?) in
                if let error = error {
                    print("Error deleting current budget from user: \(error.localizedDescription)")
                } else {
                    print("Current budget successfully deleted from user.")
                    // Optionally, update the local user object
                    authService.user?.currentBudget = nil
                }
            }

            // Add the current budget to past budgets
            self?.setupBudgetRepository.addCurrentBudgetToPastBudgets(userId: userId, currentBudget: currentBudget) { error in
                if let error = error {
                    print("Error adding current budget to past budgets: \(error.localizedDescription)")
                } else {
                    print("Current budget successfully added to past budgets.")
                }
            }
        }
    }

    func fetchUserBudgets(authService: AuthService) {
        guard let userId = authService.user?.id else {
            print("User ID not available")
            return
        }

        let db = Firestore.firestore()
        db.collection("budgets").whereField("userId", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching budgets: \(error.localizedDescription)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    // Handle the fetched budgets as needed
                }
            }
        }
    }
} 