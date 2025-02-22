import Foundation

class ChatViewModel: ObservableObject {
    private let chatRepository: ChatRepository
    
    init(chatRepository: ChatRepository = .shared) {
        self.chatRepository = chatRepository
    }
    
    // Example function to load chat messages
    func loadChatMessages() {
        chatRepository.fetchChatMessages { messages in
            // Handle the fetched messages
            print("Fetched messages: \(messages)")
        }
    }
    
    // Example function to send a chat message
    func sendMessage(_ message: String) {
        chatRepository.sendChatMessage(message) { success in
            if success {
                print("Message sent successfully")
            } else {
                print("Failed to send message")
            }
        }
    }
} 