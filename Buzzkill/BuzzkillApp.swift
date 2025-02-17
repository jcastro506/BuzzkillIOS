//
//  BuzzkillApp.swift
//  Buzzkill
//
//  Created by Josh Castro on 2/10/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct BuzzkillApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var budgetModel = BudgetModel() // ✅ Shared Data Model
    @StateObject private var authService = AuthService() // Add this line

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(budgetModel)
                .environmentObject(authService) // Pass authService to the environment
        }
    }
}
