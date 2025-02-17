import SwiftUI

struct ChatView: View {
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(id: UUID(), senderId: "bot", senderName: "BudgetBot", message: "Hey there! How can I help with your budget today?", timestamp: Date(), isSentByCurrentUser: false)
    ]
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
                VStack(alignment: .leading) {
                    Text("BudgetBot")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Online")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                Spacer()
            }
            .padding()
            .background(Color.black)
            
            // Chat Messages List
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .background(Color.black)
                .onChange(of: messages.count) { _ in
                    if let lastMessage = messages.last {
                        scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            // Input Bar
            HStack {
                TextField("Type a message...", text: $messageText)
                    .padding(12)
                    .background(Color(.darkGray))
                    .cornerRadius(20)
                    .foregroundColor(.white)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .padding()
            .background(Color.black)
        }
        .background(Color.black)
    }
    
    func sendMessage() {
        let userMessage = ChatMessage(id: UUID(), senderId: "user", senderName: "You", message: messageText, timestamp: Date(), isSentByCurrentUser: true)
        messages.append(userMessage)
        messageText = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let botResponse = ChatMessage(id: UUID(), senderId: "bot", senderName: "BudgetBot", message: generateBotResponse(for: userMessage.message), timestamp: Date(), isSentByCurrentUser: false)
            messages.append(botResponse)
        }
    }
    
    func generateBotResponse(for input: String) -> String {
        if input.lowercased().contains("budget") {
            return "You've spent 65% of your budget this week. Want to slow down?"
        } else {
            return "I'm here to help! Ask me anything about your spending."
        }
    }
}

struct ChatBubble: View {
    var message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isSentByCurrentUser {
                Spacer()
                Text(message.message)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            } else {
                Text(message.message)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(15)
                Spacer()
            }
        }
    }
}

struct ChatScreen_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .preferredColorScheme(.dark)
    }
}
