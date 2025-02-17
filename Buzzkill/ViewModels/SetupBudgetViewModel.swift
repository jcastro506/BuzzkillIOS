import Foundation
import SwiftUI
import CoreLocation
import ActivityKit

class SetupBudgetViewModel: ObservableObject {
    @Published var budgetAmount: String = "50"
    @Published var overBudgetAlert: Bool = false
    @Published var autoStartBudget: Bool = false
    @Published var showAutoStartPrompt: Bool = false
    @Published var showInfoAlert: Bool = false
    @Published var infoMessage: String = ""
    @Published var showConfirmationAlert: Bool = false
    
    var locationManager = LocationManager()
    var budgetModel: BudgetModel

    init(budgetModel: BudgetModel) {
        self.budgetModel = budgetModel
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
        if let amount = Double(budgetAmount) {
            budgetModel.budgetAmount = amount
            UserDefaults.standard.set(amount, forKey: "userBudget")
            startBudgetLiveActivity(amount: amount)
            showConfirmationAlert = true
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
} 