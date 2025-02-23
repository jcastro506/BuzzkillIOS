import Foundation

struct PastBudget: Identifiable {
    var id: UUID
    var userId: String
    var totalAmount: Double
    var spentAmount: Double
    var name: String
    var startDate: Date
    var endDate: Date
    var isRecurring: Bool
    var status: String
    var transactions: [Transaction]

    var isUnderBudget: Bool {
        return spentAmount <= totalAmount
    }
    
    var overspentAmount: Double {
        return max(0, spentAmount - totalAmount)
    }
    
    var underspentAmount: Double {
        return max(0, totalAmount - spentAmount)
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "userId": userId,
            "totalAmount": totalAmount,
            "spentAmount": spentAmount,
            "name": name,
            "startDate": startDate.timeIntervalSince1970,
            "endDate": endDate.timeIntervalSince1970,
            "isRecurring": isRecurring,
            "status": status,
            "transactions": transactions.map { $0.toDictionary() }
        ]
    }
    
    static func fromDictionary(_ data: [String: Any]) -> PastBudget? {
        guard let idString = data["id"] as? String,
              let uuid = UUID(uuidString: idString),
              let userId = data["userId"] as? String,
              let totalAmount = data["totalAmount"] as? Double,
              let spentAmount = data["spentAmount"] as? Double,
              let name = data["name"] as? String,
              let startDate = data["startDate"] as? TimeInterval,
              let endDate = data["endDate"] as? TimeInterval,
              let isRecurring = data["isRecurring"] as? Bool,
              let status = data["status"] as? String,
              let transactionsData = data["transactions"] as? [[String: Any]] else {
            return nil
        }

        let transactions = transactionsData.compactMap { Transaction.fromDictionary($0) }

        return PastBudget(
            id: uuid,
            userId: userId,
            totalAmount: totalAmount,
            spentAmount: spentAmount,
            name: name,
            startDate: Date(timeIntervalSince1970: startDate),
            endDate: Date(timeIntervalSince1970: endDate),
            isRecurring: isRecurring,
            status: status,
            transactions: transactions
        )
    }
} 
