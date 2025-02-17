import SwiftUI

struct CardViewComponent: View {
    var title: String
    var content: String

    var body: some View {
        VStack {
            Text(title)
            Text(content)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
} 