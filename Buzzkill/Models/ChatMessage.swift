import Foundation

struct ChatMessage: Identifiable {
    let id: UUID
    let senderId: String
    let senderName: String
    let message: String
    let timestamp: Date
    let isSentByCurrentUser: Bool
} 