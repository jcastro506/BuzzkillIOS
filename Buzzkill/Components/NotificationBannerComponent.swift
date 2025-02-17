import SwiftUI

struct NotificationBannerComponent: View {
    var message: String

    var body: some View {
        Text(message)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
} 