import SwiftUI

struct BudgetDetailView: View {
    let budget: PastBudget

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(budget.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Start Date: \(budget.startDate, style: .date)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("End Date: \(budget.endDate, style: .date)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Total Budget: $\(budget.totalAmount, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.green)
                
                Spacer()
                
                Text("Spent: $\(budget.spentAmount, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.red)
            }
            
            Divider()
            
            Text("Transactions")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 8)

            if budget.transactions.isEmpty {
                Text("No transactions recorded.")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(budget.transactions) { transaction in
                            PastBudgetTransactionRow(transaction: transaction)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding()
    }
}

struct BudgetDetailRow: View {
    let title: String
    let amount: Double
    let color: Color

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text("$\(amount, specifier: "%.2f")")
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(.horizontal, 4)
    }
}

struct PastBudgetTransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(transaction.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("-$\(transaction.amount, specifier: "%.2f")")
                    .fontWeight(.bold)
                    .foregroundColor(.red)

                Text(transaction.date, style: .date)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct BudgetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let budget = Budget(
            id: UUID(),
            userId: "sampleUserId",
            totalAmount: 100.00,
            spentAmount: 80.00,
            name: "Neon Lights Bar",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
            isRecurring: false,
            status: "completed",
            transactions: [
                Transaction(id: UUID(), amount: 20.00, date: Date(), description: "Drinks", name: "Cocktail"),
                Transaction(id: UUID(), amount: 15.00, date: Date(), description: "Snacks", name: "Nachos"),
                Transaction(id: UUID(), amount: 30.00, date: Date(), description: "Entry Fee", name: "Cover Charge")
            ]
        )
        
        BudgetDetailView(budget: PastBudget(
            id: UUID(),
            userId: "sampleUserId",
            totalAmount: budget.totalAmount,
            spentAmount: budget.spentAmount,
            name: budget.name,
            startDate: budget.startDate,
            endDate: budget.endDate,
            isRecurring: budget.isRecurring,
            status: budget.status,
            transactions: budget.transactions
        ))
        .preferredColorScheme(.dark)
    }
} 
