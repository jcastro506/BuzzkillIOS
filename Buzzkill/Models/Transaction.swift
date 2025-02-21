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
} 