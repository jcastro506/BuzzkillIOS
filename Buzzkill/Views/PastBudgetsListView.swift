import SwiftUI

struct PastBudgetsListView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel: PastBudgetsViewModel
    @State private var selectedBudget: PastBudget?
    @State private var showBudgetDetail = false

    init(viewModel: PastBudgetsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

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
                        ForEach(viewModel.pastBudgets) { budget in
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

                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
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
            // Always fetch all user past budgets on appear to ensure up-to-date information
            viewModel.fetchAllUserPastBudgets(userId: authService.user?.id ?? "")
        }
    }
}

struct PastBudgetLiveViewHeaderView: View {
    @EnvironmentObject var authService: AuthService

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

                NavigationLink(destination: ProfileView(authService: authService)) {
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
            Text(budget.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(budget.startDate, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Spent: \(budget.spentAmount, specifier: "%.2f")")
                    .foregroundColor(.red)
                Spacer()
                Text("Budget: \(budget.totalAmount, specifier: "%.2f")")
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
        let pastBudget = PastBudget(
            id: UUID(),
            userId: "sampleUserId",
            totalAmount: 100.00,
            spentAmount: 80.00,
            name: "Sample Budget Name",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
            isRecurring: false,
            status: "completed",
            transactions: [
                Transaction(id: UUID(), amount: 20, date: Date(), description: "Sample Transaction", name: "Sample Name")
            ]
        )
        sampleBudgetModel.pastBudgets = [pastBudget]
        
        return PastBudgetsListView(viewModel: PastBudgetsViewModel(authService: AuthService(), pastBudgetsRepository: PastBudgetsRepository.shared))
            .environmentObject(AuthService())
            .preferredColorScheme(.dark)
    }
}
