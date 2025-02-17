//
//  BuzzkillApp.swift
//  Buzzkill
//
//  Created by Josh Castro on 2/10/25.
//

import SwiftUI

@main
struct BuzzkillApp: App {
    @StateObject private var budgetModel = BudgetModel() // ✅ Shared Data Model

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(budgetModel)
        }
    }
}
