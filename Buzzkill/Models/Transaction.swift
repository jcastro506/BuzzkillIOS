import Foundation

struct Transaction: Identifiable, Equatable {
    let id: UUID
    let amount: Double
    let date: Date
    let description: String
    let name: String
    // Add other transaction properties here
} 