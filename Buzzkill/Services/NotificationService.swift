import Foundation
import UserNotifications

class NotificationService {
    // Add notification management logic here

    func scheduleNotification(for friend: Friend, budgetAmount: Double) {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Budget Update"
        content.body = "\(friend.name), your friend has set a new budget of $\(budgetAmount)."
        content.sound = .default

        // Create a time interval trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // Create a notification request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // Add the notification request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
} 