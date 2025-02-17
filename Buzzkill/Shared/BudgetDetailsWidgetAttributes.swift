import ActivityKit

struct BudgetDetailsWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var totalBudget: Double
        var amountSpent: Double
        var amountRemaining: Double
    }

    var name: String
} 