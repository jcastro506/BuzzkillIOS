import SwiftUI

struct BudgetDetailView: View {
    let budget: PastBudget

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(budget.barName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(budget.date)
                .font(.title3)
                .foregroundColor(.secondary)
            
            Divider()
            
            VStack(spacing: 10) {
                BudgetDetailRow(title: "Spent:", amount: budget.amountSpent, color: .red)
                BudgetDetailRow(title: "Budget:", amount: budget.budget, color: .green)
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
        BudgetDetailView(budget: PastBudget(
            barName: "Neon Lights Bar",
            date: "Feb 3, 2025",
            amountSpent: 80.00,
            budget: 100.00,
            transactions: [
                Transaction(id: UUID(), amount: 20.00, date: Date(), description: "Drinks", name: "Cocktail"),
                Transaction(id: UUID(), amount: 15.00, date: Date(), description: "Snacks", name: "Nachos"),
                Transaction(id: UUID(), amount: 30.00, date: Date(), description: "Entry Fee", name: "Cover Charge")
            ]
        ))
        .preferredColorScheme(.dark)
    }
} 
