import SwiftUI

struct PastBudgetsListView: View {
    @EnvironmentObject var budgetModel: BudgetModel
    @State private var selectedBudget: PastBudget?
    @State private var showBudgetDetail = false
    @State private var isLoading = false
    @State private var currentPage = 0
    private let pageSize = 10

    // Define grid layout for two columns
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                PastBudgetLiveViewHeaderView() // Header remains fixed

                ScrollView {
                    Text("Past Budgets")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(budgetModel.pastBudgets) { budget in
                            PastBudgetCard(budget: budget)
                                .onTapGesture {
                                    withAnimation {
                                        selectedBudget = budget
                                        showBudgetDetail = true
                                    }
                                }
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .padding(8)
                        }

                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Color.clear
                                .onAppear {
                                    loadMoreBudgets()
                                }
                        }
                    }
                    .padding(.horizontal, 16) // Ensure proper padding around grid
                    .padding(.top, 8)
                }
                .sheet(isPresented: $showBudgetDetail) {
                    if let budget = selectedBudget {
                        BudgetDetailView(budget: budget)
                    }
                }
            }
        }
        .onAppear {
            if budgetModel.pastBudgets.isEmpty {
                loadInitialBudgets()
            }
        }
    }

    private func loadInitialBudgets() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            budgetModel.pastBudgets = generateDummyBudgets(page: 0, size: pageSize)
            isLoading = false
        }
    }

    private func loadMoreBudgets() {
        guard !isLoading else { return }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let newBudgets = generateDummyBudgets(page: currentPage + 1, size: pageSize)
            budgetModel.pastBudgets.append(contentsOf: newBudgets)
            currentPage += 1
            isLoading = false
        }
    }

    private func generateDummyBudgets(page: Int, size: Int) -> [PastBudget] {
        let barNames = [
            "The Tipsy Tavern", "Neon Nights", "The Rusty Nail", 
            "Moonlight Lounge", "The Happy Hour", "The Drunken Duck", 
            "The Buzz Bar", "The Liquid Lounge", "The Velvet Room", 
            "The Whiskey Way"
        ]
        
        return (0..<size).map { index in
            PastBudget(
                barName: barNames[(page * size + index) % barNames.count],
                date: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none),
                amountSpent: Double.random(in: 50...500),
                budget: Double.random(in: 500...1000),
                transactions: generateDummyTransactions()
            )
        }
    }

    private func generateDummyTransactions() -> [Transaction] {
        return (0..<5).map { index in
            Transaction(
                id: UUID(),
                amount: Double.random(in: 10...100),
                date: Date(),
                description: "Transaction \(index + 1)",
                name: "Transaction Name \(index + 1)"
            )
        }
    }
}

struct PastBudgetLiveViewHeaderView: View {
    var body: some View {
        HStack {
            Text("Buzzkill")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(.leading, 16)

            Spacer()

            HStack(spacing: 16) {
                NavigationLink(destination: NotificationsView()) {
                    Image(systemName: "bell.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                }

                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                }
            }
            .padding(.trailing, 16)
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(Color.black)
    }
}

struct PastBudgetCard: View {
    let budget: PastBudget

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(budget.barName)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(budget.date)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Spent: \(budget.amountSpent, specifier: "%.2f")")
                    .foregroundColor(.red)
                Spacer()
                Text("Budget: \(budget.budget, specifier: "%.2f")")
                    .foregroundColor(.green)
            }
            .font(.footnote)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct PastBudgetsListView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleBudgetModel = BudgetModel()
        sampleBudgetModel.pastBudgets = [
            PastBudget(barName: "Neon Lights Bar", date: "Feb 3, 2025", amountSpent: 80.00, budget: 100.00, transactions: [])
        ]
        
        return PastBudgetsListView()
            .environmentObject(sampleBudgetModel)
            .preferredColorScheme(.dark)
    }
}
