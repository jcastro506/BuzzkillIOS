import SwiftUI

struct TextFieldComponent: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        TextField(placeholder, text: $text)
    }
} 