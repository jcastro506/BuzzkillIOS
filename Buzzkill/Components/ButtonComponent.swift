import SwiftUI

struct ButtonComponent: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
        }
    }
} 