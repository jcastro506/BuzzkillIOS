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
        
        if user.currentBudget != nil {
            showActiveBudgetAlert = true
        } else if let amount = Double(budgetAmount) {
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
            
            saveBudget(budget: budget, authService: authService)
        }
    }

    private func saveBudget(budget: Budget, authService: AuthService) {
        setupBudgetRepository.saveBudgetToFirestore(budget: budget) { [weak self] error in
            if let error = error {
                print("Error saving budget: \(error.localizedDescription)")
            } else {
                // Update the local user object
                authService.user?.currentBudget = budget
                
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
        guard let user = authService.user, let currentBudget = user.currentBudget else { return }
        
        // Create a PastBudget from the current budget
        let pastBudget = PastBudget(
            id: UUID(),
            userId: user.id,
            totalAmount: currentBudget.totalAmount,
            spentAmount: currentBudget.spentAmount,
            name: currentBudget.name,
            startDate: currentBudget.startDate,
            endDate: currentBudget.endDate,
            isRecurring: currentBudget.isRecurring,
            status: "completed",
            transactions: currentBudget.transactions
        )
        
        // Add the past budget to Firestore
        setupBudgetRepository.addPastBudgetToUser(userId: user.id, pastBudget: pastBudget) { [weak self] error in
            if let error = error {
                print("Error adding past budget: \(error.localizedDescription)")
            } else {
                print("Past budget successfully added!")
                
                // Remove the current budget
                authService.user?.currentBudget = nil
                
                // Update Firestore
                let userRef = self?.db.collection("users").document(user.id)
                userRef?.updateData([
                    "current_budget": FieldValue.delete()
                ]) { error in
                    if let error = error {
                        print("Error updating Firestore: \(error.localizedDescription)")
                    } else {
                        print("Current budget successfully removed!")
                    }
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