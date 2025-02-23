import Foundation

struct PastBudget: Identifiable {
    let id: UUID
    let userId: String
    let totalAmount: Double
    let spentAmount: Double
    let name: String
    let startDate: Date
    let endDate: Date
    let isRecurring: Bool
    let status: String
    let transactions: [Transaction]

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
    
    static func fromDictionary(_ dict: [String: Any]) -> PastBudget? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let userId = dict["userId"] as? String,
              let totalAmount = dict["totalAmount"] as? Double,
              let spentAmount = dict["spentAmount"] as? Double,
              let name = dict["name"] as? String,
              let startDateTimestamp = dict["startDate"] as? TimeInterval,
              let endDateTimestamp = dict["endDate"] as? TimeInterval,
              let isRecurring = dict["isRecurring"] as? Bool,
              let status = dict["status"] as? String else {
            return nil
        }

        let startDate = Date(timeIntervalSince1970: startDateTimestamp)
        let endDate = Date(timeIntervalSince1970: endDateTimestamp)

        let transactionsData = dict["transactions"] as? [[String: Any]] ?? []
        let transactions = transactionsData.compactMap { Transaction.fromDictionary($0) }

        return PastBudget(
            id: id,
            userId: userId,
            totalAmount: totalAmount,
            spentAmount: spentAmount,
            name: name,
            startDate: startDate,
            endDate: endDate,
            isRecurring: isRecurring,
            status: status,
            transactions: transactions
        )
    }
} 
