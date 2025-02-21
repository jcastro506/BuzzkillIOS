import Foundation
import SwiftUI
import CoreLocation
import ActivityKit
import FirebaseFirestore

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
    var budgetModel: BudgetModel
    var userId: String
    private let db = Firestore.firestore()

    init(budgetModel: BudgetModel, userId: String) {
        self.budgetModel = budgetModel
        self.userId = userId
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
        checkForActiveBudget { hasActiveBudget in
            if hasActiveBudget {
                self.showActiveBudgetAlert = true
            } else if let amount = Double(self.budgetAmount) {
                self.budgetModel.budgetAmount = amount
                UserDefaults.standard.set(amount, forKey: "userBudget")
                self.saveBudgetToFirestore(amount: amount)
                self.startBudgetLiveActivity(amount: amount)
                self.showConfirmationAlert = true
            }
        }
    }

    private func checkForActiveBudget(completion: @escaping (Bool) -> Void) {
        db.collection("budgets")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "active")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error checking active budget: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(querySnapshot?.documents.isEmpty == false)
                }
            }
    }

    func saveBudgetToFirestore(amount: Double) {
        let budget = Budget(
            id: UUID(),
            userId: userId,
            totalAmount: amount,
            spentAmount: 0.0,
            name: "New Budget",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
            isRecurring: false,
            status: "active",
            transactions: []
        )
        
        db.collection("budgets").document(budget.id.uuidString).setData(budget.toDictionary()) { error in
            if let error = error {
                print("Error saving budget: \(error.localizedDescription)")
            } else {
                print("Budget successfully saved!")
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
        db.collection("budgets")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: "active")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching active budget: \(error.localizedDescription)")
                } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                    for document in documents {
                        let budgetData = document.data()
                        let pastBudget = PastBudget(
                            barName: budgetData["name"] as? String ?? "Unknown",
                            date: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none),
                            amountSpent: budgetData["spentAmount"] as? Double ?? 0.0,
                            budget: budgetData["totalAmount"] as? Double ?? 0.0,
                            transactions: [] // Assuming transactions are not stored in the budget document
                        )
                        
                        // Update the budget status to "cancelled"
                        document.reference.updateData(["status": "cancelled"]) { error in
                            if let error = error {
                                print("Error cancelling budget: \(error.localizedDescription)")
                            } else {
                                print("Budget successfully cancelled!")
                                self.addPastBudgetToUser(pastBudget: pastBudget)
                            }
                        }
                    }
                } else {
                    print("No active budget found to cancel.")
                }
            }
    }

    private func addPastBudgetToUser(pastBudget: PastBudget) {
        let userRef = db.collection("users").document(userId)
        userRef.updateData([
            "pastBudgets": FieldValue.arrayUnion([pastBudget.toDictionary()])
        ]) { error in
            if let error = error {
                print("Error adding past budget: \(error.localizedDescription)")
            } else {
                print("Past budget successfully added!")
            }
        }
    }
} 