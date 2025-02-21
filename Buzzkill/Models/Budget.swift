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

