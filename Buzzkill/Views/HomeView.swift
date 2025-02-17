import SwiftUI
import ActivityKit

struct HomeView: View {
    @EnvironmentObject var budgetModel: BudgetModel // Access the shared data model
    @StateObject private var viewModel = HomeViewViewModel(budgetModel: BudgetModel()) // Temporary initialization

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HomeHeaderView()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Add a header to display the active budget
                        HStack {
                            Text("Active Budget: $\(String(format: "%.2f", budgetModel.budgetAmount))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 0)
                            Spacer()
                        }
                        .padding(.top, 10)
                        
                        BudgetProgressView(budget: budgetModel.budgetAmount, spent: viewModel.spent) // Use the shared budget amount
                        PastBudgetsView(
                            selectedPastBudget: $viewModel.selectedPastBudget,
                            showBudgetDetailModal: $viewModel.showBudgetDetailModal
                        )
                        
                        CurrentTransactionsView(
                            transactions: $viewModel.transactions,
                            selectedTransaction: $viewModel.selectedTransaction,
                            showEditSheet: $viewModel.showEditSheet
                        )
                        
                        Button(action: viewModel.addDummyTransaction) {
                            Text("Add Dummy Transaction")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.black)
            .onAppear {
                if viewModel.budgetModel.budgetAmount == 0 {
                    viewModel.budgetModel = budgetModel
                    viewModel.updateSpentAmount()
                }
            }
            .sheet(isPresented: $viewModel.showEditSheet) {
                if let transaction = viewModel.selectedTransaction {
                    EditTransactionView(transaction: transaction, transactions: $viewModel.transactions, onSave: viewModel.updateSpentAmount)
                }
            }
            .sheet(isPresented: $viewModel.showBudgetDetailModal) {
                if let budget = viewModel.selectedPastBudget {
                    BudgetDetailView(budget: budget)
                }
            }
        }
    }
}

// MARK: - Home Header View
struct HomeHeaderView: View {
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

// MARK: - Budget Progress View
struct BudgetProgressView: View {
    let budget: Double
    let spent: Double
    
    var progress: Double {
        return spent / budget
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0.0, to: min(progress, 1.0))
                    .stroke(progressColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 150, height: 150)
                    .animation(.easeOut(duration: 0.8), value: progress)
                
                if progress > 1.0 {
                    Circle()
                        .trim(from: 0.0, to: progress - 1.0)
                        .stroke(Color.red, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 150, height: 150)
                        .animation(.easeOut(duration: 0.8), value: progress)
                }
                
                VStack {
                    Text("$\(String(format: "%.2f", max(0, budget - spent))) Left")
                        .font(.system(size: 20, weight: .bold))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .foregroundColor(.white)
                        .animation(.easeInOut(duration: 0.3))
                    
                    Text("\(String(format: "%.0f", progress * 100))% Spent")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .frame(width: 130) // Ensure text stays within the circle
            }
            .padding(.top, 20)
        }
    }
    
    private var progressColor: Color {
        if progress <= 0.4 {
            return Color.green
        } else if progress <= 0.7 {
            return Color.orange
        } else {
            return Color(red: 0.8, green: 0, blue: 0) // Darker red before overspending
        }
    }
}

extension Color {
    func interpolate(to color: Color, fraction: Double) -> Color {
        let clampedFraction = min(max(0, fraction), 1)
        let startComponents = self.components
        let endComponents = color.components
        
        let red = startComponents.red + (endComponents.red - startComponents.red) * clampedFraction
        let green = startComponents.green + (endComponents.green - startComponents.green) * clampedFraction
        let blue = startComponents.blue + (endComponents.blue - startComponents.blue) * clampedFraction
        
        return Color(red: red, green: green, blue: blue)
    }
    
    private var components: (red: Double, green: Double, blue: Double) {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        return (Double(red), Double(green), Double(blue))
        #else
        let nsColor = NSColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        return (Double(red), Double(green), Double(blue))
        #endif
    }
}

// MARK: - Past Budgets View
struct PastBudgetsView: View {
    let pastBudgets: [PastBudget] = [
        PastBudget(
            barName: "Neon Lights Bar",
            date: "Feb 3, 2025",
            amountSpent: 80,
            budget: 100,
            transactions: [
                Transaction(id: UUID(), amount: 20, date: Date(), description: "Drinks", name: "Neon Lights Bar"),
                Transaction(id: UUID(), amount: 60, date: Date(), description: "Food", name: "Neon Lights Bar")
            ]
        ),
        PastBudget(
            barName: "The Golden Tap",
            date: "Jan 27, 2025",
            amountSpent: 120,
            budget: 100,
            transactions: [
                Transaction(id: UUID(), amount: 50, date: Date(), description: "Drinks", name: "The Golden Tap"),
                Transaction(id: UUID(), amount: 70, date: Date(), description: "Food", name: "The Golden Tap")
            ]
        ),
        PastBudget(
            barName: "Midnight Lounge",
            date: "Jan 20, 2025",
            amountSpent: 90,
            budget: 100,
            transactions: [
                Transaction(id: UUID(), amount: 30, date: Date(), description: "Drinks", name: "Midnight Lounge"),
                Transaction(id: UUID(), amount: 60, date: Date(), description: "Food", name: "Midnight Lounge")
            ]
        ),
        PastBudget(
            barName: "Electric Avenue",
            date: "Jan 15, 2025",
            amountSpent: 70,
            budget: 100,
            transactions: [
                Transaction(id: UUID(), amount: 40, date: Date(), description: "Drinks", name: "Electric Avenue"),
                Transaction(id: UUID(), amount: 30, date: Date(), description: "Food", name: "Electric Avenue")
            ]
        )
    ]
    @Binding var selectedPastBudget: PastBudget?
    @Binding var showBudgetDetailModal: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Past Budgets")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 0)

            TabView {
                ForEach(pastBudgets.indices, id: \.self) { index in
                    BudgetCard(budget: pastBudgets[index])
                        .frame(width: 300, height: 180)
                        .padding(.horizontal, 8) // Adjust padding for closer spacing
                        .onTapGesture {
                            selectedPastBudget = pastBudgets[index]
                            showBudgetDetailModal = true
                        }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 220) // Increase height to move dots further down
            .padding(.bottom, 20) // Add padding to move dots further down
        }
    }
}

// MARK: - Transactions View
struct CurrentTransactionsView: View {
    @Binding var transactions: [Transaction]
    @Binding var selectedTransaction: Transaction?
    @Binding var showEditSheet: Bool
    
    @State private var showAllTransactions = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Transactions")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            LazyVStack(spacing: 12) {
                ForEach(showAllTransactions ? transactions : Array(transactions.prefix(3)), id: \.id) { transaction in
                    TransactionRow(transaction: transaction) {
                        selectedTransaction = transaction
                        showEditSheet = true
                    }
                }
            }
            
            Button(action: {
                showAllTransactions.toggle()
            }) {
                Text(showAllTransactions ? "Show Less" : "View All")
                    .font(.body)
                    .foregroundColor(.blue)
            }
            .padding(.top, 10)
            .animation(.easeInOut(duration: 0.2), value: showAllTransactions)
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    var onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.description)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(transaction.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("-$\(String(format: "%.2f", transaction.amount))")
                .font(.headline)
                .foregroundColor(.red)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.3), Color.white.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.6), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
        .onTapGesture {
            onEdit()
        }
    }
}

struct EditTransactionView: View {
    var transaction: Transaction
    @Binding var transactions: [Transaction]
    var onSave: () -> Void

    @State private var newDescription: String
    @State private var newAmount: String

    @Environment(\.presentationMode) var presentationMode

    init(transaction: Transaction, transactions: Binding<[Transaction]>, onSave: @escaping () -> Void) {
        self.transaction = transaction
        self._transactions = transactions
        self.onSave = onSave
        _newDescription = State(initialValue: transaction.description)
        _newAmount = State(initialValue: String(format: "%.2f", transaction.amount))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Edit Transaction")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)

                    Text("Description")
                        .font(.headline)
                        .foregroundColor(.gray)
                    TextField("Enter description", text: $newDescription)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        .foregroundColor(.white)

                    Text("Amount")
                        .font(.headline)
                        .foregroundColor(.gray)
                    TextField("Enter amount", text: $newAmount)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)

                HStack(spacing: 20) {
                    Button(action: saveChanges) {
                        Text("Save")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: deleteTransaction) {
                        Text("Delete")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    private func saveChanges() {
        if let amount = Double(newAmount) {
            if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
                transactions[index] = Transaction(
                    id: transaction.id,
                    amount: amount,
                    date: transaction.date,
                    description: newDescription,
                    name: transaction.name
                )
                onSave()
            }
        }
        presentationMode.wrappedValue.dismiss()
    }

    private func deleteTransaction() {
        transactions.removeAll { $0.id == transaction.id }
        onSave()
        presentationMode.wrappedValue.dismiss()
    }
}

struct BudgetCard: View {
    let budget: PastBudget
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.barName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(budget.date)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                
                Text(budget.isUnderBudget ? "✔️" : "⚠️")
                    .font(.title2)
                    .foregroundColor(budget.isUnderBudget ? .green : .red)
            }
            
            ProgressView(value: progressValue)
                .progressViewStyle(LinearProgressViewStyle(tint: budget.isUnderBudget ? Color.green : Color.red))
                .frame(height: 8)
                .cornerRadius(4)
                .padding(.vertical, 4)
            
            HStack {
                Text("Spent: $\(String(format: "%.2f", budget.amountSpent))")
                    .font(.footnote)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Budget: $\(String(format: "%.2f", budget.budget))")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .frame(width: 260, height: 140)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.3), Color.gray.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.6), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white, lineWidth: 2)
                .shadow(color: Color.white.opacity(0.6), radius: 10, x: 0, y: 5)
        )
    }
    
    private var progressValue: Double {
        guard budget.budget > 0 else { return 0 }
        return min(max(budget.amountSpent / budget.budget, 0), 1)
    }
}

struct BudgetCarouselView: View {
    let budgets: [PastBudget]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(budgets) { budget in
                    BudgetCard(budget: budget)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample BudgetModel with mock data
        let sampleBudgetModel = BudgetModel()
        sampleBudgetModel.budgetAmount = 200.0 // Set a sample budget amount

        return HomeView()
            .environmentObject(sampleBudgetModel) // Provide the sample model to the environment
            .preferredColorScheme(.dark)
    }
}
