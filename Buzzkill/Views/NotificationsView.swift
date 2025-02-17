import SwiftUI

struct NotificationsView: View {
    @State private var notifications: [String] = [
        "You stayed under budget last night! 🎉",
        "New spending trend detected: You're spending more on weekends.",
        "Reminder: Set your budget before going out tonight!"
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Text("Notifications")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                Divider()
                    .background(Color.gray.opacity(0.6))
                    .padding(.horizontal)
                
                List {
                    ForEach(notifications, id: \.self) { notification in
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.yellow)
                            Text(notification)
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color.black)
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
            .preferredColorScheme(.dark)
    }
}