import Foundation

struct Transaction: Identifiable, Equatable {
    let id: UUID
    let amount: Double
    let date: Date
    let description: String
    let name: String
    // Add other transaction properties here

    // Add this method to convert Transaction to a dictionary
    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "amount": amount,
            "date": date.timeIntervalSince1970, // Convert Date to timestamp
            "description": description,
            "name": name
        ]
    }

    static func fromDictionary(_ dict: [String: Any]) -> Transaction? {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let amount = dict["amount"] as? Double,
              let dateTimestamp = dict["date"] as? TimeInterval,
              let description = dict["description"] as? String,
              let name = dict["name"] as? String else {
            return nil
        }

        let date = Date(timeIntervalSince1970: dateTimestamp)

        return Transaction(
            id: id,
            amount: amount,
            date: date,
            description: description,
            name: name
        )
    }
} 