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
    private let setupBudgetRepository: SetupBudgetRepositoryProtocol

    init(budgetModel: BudgetModel, userId: String, setupBudgetRepository: SetupBudgetRepositoryProtocol = SetupBudgetRepository()) {
        self.budgetModel = budgetModel
        self.userId = userId
        self.setupBudgetRepository = setupBudgetRepository
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

    func lockInBudget() {
        setupBudgetRepository.checkForActiveBudget(userId: userId) { [weak self] hasActiveBudget, error in
            if let error = error {
                print("Error checking active budget: \(error.localizedDescription)")
                return
            }
            if hasActiveBudget {
                self?.showActiveBudgetAlert = true
            } else if let amount = Double(self?.budgetAmount ?? "") {
                self?.budgetModel.budgetAmount = amount
                UserDefaults.standard.set(amount, forKey: "userBudget")
                let budget = Budget(
                    id: UUID(),
                    userId: self?.userId ?? "",
                    totalAmount: amount,
                    spentAmount: 0.0,
                    name: "New Budget",
                    startDate: Date(),
                    endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
                    isRecurring: false,
                    status: "active",
                    transactions: []
                )
                self?.setupBudgetRepository.saveBudgetToFirestore(budget: budget) { error in
                    if let error = error {
                        print("Error saving budget: \(error.localizedDescription)")
                    } else {
                        print("Budget successfully saved!")
                        self?.startBudgetLiveActivity(amount: amount)
                        self?.showConfirmationAlert = true
                    }
                }
            }
        }
    }

    private func startBudgetLiveActivity(amount: Double) {
        let attributes = BudgetDetailsWidgetAttributes(name: "Buzzkill Budget")
        let contentState = BudgetDetailsWidgetAttributes.ContentState(
            totalBudget: amount,
            amountSpent: 0.0,
            amountRemaining: amount
        )
        
        do {
            let activity = try Activity<BudgetDetailsWidgetAttributes>.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            print("Started Live Activity: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: \(error.localizedDescription)")
        }
    }

    func cancelActiveBudget() {
        setupBudgetRepository.cancelActiveBudget(userId: userId) { [weak self] error in
            if let error = error {
                print("Error cancelling budget: \(error.localizedDescription)")
            } else {
                print("Budget successfully cancelled!")
                // Assuming you have logic to create a PastBudget instance
                let pastBudget = PastBudget(
                    barName: "Unknown",
                    date: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none),
                    budget: Budget(id: UUID(), userId: self?.userId ?? "", totalAmount: 0.0, spentAmount: 0.0, name: "Unknown", startDate: Date(), endDate: Date(), isRecurring: false, status: "cancelled", transactions: []),
                    transactions: []
                )
                self?.setupBudgetRepository.addPastBudgetToUser(userId: self?.userId ?? "", pastBudget: pastBudget) { error in
                    if let error = error {
                        print("Error adding past budget: \(error.localizedDescription)")
                    } else {
                        print("Past budget successfully added!")
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