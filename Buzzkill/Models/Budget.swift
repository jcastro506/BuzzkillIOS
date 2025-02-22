import Foundation

struct Budget {
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
    // Placeholder for transactions subcollection
    // var transactions: [Transaction]?
    // Add other budget properties here

    static func fromDictionary(_ dict: [String: Any]) -> Budget? {
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

        // Assuming transactions are stored as an array of dictionaries
        let transactionsData = dict["transactions"] as? [[String: Any]] ?? []
        let transactions = transactionsData.compactMap { Transaction.fromDictionary($0) }

        return Budget(
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

extension Budget {
    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "userId": userId,
            "totalAmount": totalAmount,
            "spentAmount": spentAmount,
            "name": name,
            "startDate": startDate,
            "endDate": endDate,
            "isRecurring": isRecurring,
            "status": status
        ]
    }
}

