//
//  BudgetDetailsWidgetLiveActivity.swift
//  BudgetDetailsWidget
//
//  Created by Josh Castro on 2/16/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BudgetDetailsWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var totalBudget: Double
        var amountSpent: Double
        var amountRemaining: Double
    }

    var name: String
}

struct BudgetDetailsWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BudgetDetailsWidgetAttributes.self) { context in
            let budgetProgress = context.state.amountSpent / context.state.totalBudget
            let progressColor: Color = budgetProgress >= 1.0 ? .red : .green
            
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("Budget Overview")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    // Progress Indicator
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 8)
                            .foregroundColor(.gray.opacity(0.3))
                        
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: max(10, UIScreen.main.bounds.width * CGFloat(budgetProgress) * 0.75), height: 8)
                            .foregroundColor(progressColor)
                            .animation(.easeInOut(duration: 0.5), value: budgetProgress)
                    }
                    
                    // Spending Breakdown
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Remaining")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("$\(context.state.amountRemaining, specifier: "%.2f")")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Spent")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("$\(context.state.amountSpent, specifier: "%.2f")")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } dynamicIsland: { context in
            let progressColor: Color = context.state.amountSpent >= context.state.totalBudget ? .red : .green
            
            return DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 4) {
                        Text("Remaining: $\(context.state.amountRemaining, specifier: "%.2f")")
                            .font(.title3)
                            .bold()
                            .foregroundColor(progressColor)
                        Text("Spent: **$\(context.state.amountSpent, specifier: "%.2f")**")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            } compactLeading: {
                Text("$\(context.state.amountRemaining, specifier: "%.0f")")
                    .font(.footnote)
                    .bold()
                    .foregroundColor(.white)
            } compactTrailing: {
                Text("💸")
            } minimal: {
                Text("$\(context.state.amountRemaining, specifier: "%.0f")")
            }
            .widgetURL(URL(string: "buzzkill://budget"))
            .keylineTint(progressColor)
        }
    }
}

extension BudgetDetailsWidgetAttributes {
    fileprivate static var preview: BudgetDetailsWidgetAttributes {
        BudgetDetailsWidgetAttributes(name: "Buzzkill Budget")
    }
}

extension BudgetDetailsWidgetAttributes.ContentState {
    fileprivate static var sampleData: BudgetDetailsWidgetAttributes.ContentState {
        BudgetDetailsWidgetAttributes.ContentState(
            totalBudget: 100.0,
            amountSpent: 50.0,
            amountRemaining: 50.0
        )
    }
}

//#Preview("Notification", as: .content, using: BudgetDetailsWidgetAttributes.preview) {
//   BudgetDetailsWidgetLiveActivity()
//} contentStates: {
//    BudgetDetailsWidgetAttributes.ContentState.sampleData
//}

func updateLiveActivity(with newAmountSpent: Double, totalBudget: Double) {
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

func addTransaction(amount: Double, currentAmountSpent: Double, totalBudget: Double) {
    // Calculate the new amount spent
    let newAmountSpent = currentAmountSpent + amount
    
    // Update your data model with the new transaction
    // For example, save the newAmountSpent to your data store
    // ...

    // Update the Live Activity
    updateLiveActivity(with: newAmountSpent, totalBudget: totalBudget)
}
