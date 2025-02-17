import SwiftUI

struct ConnectCardView: View {
    var onComplete: () -> Void // Completion handler

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Image(systemName: "creditcard.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 60)
                    .foregroundColor(.blue)
                    
                Text("Connect Your Card")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                Text("To create a budget, securely connect your card. This allows us to track your spending and help you stay on top of your finances.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Button(action: {
                    // Implement card connection logic here
                }) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.white)
                        Text("Securely Connect Card")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                }
                .padding(.horizontal, 30)
                
                Button(action: {
                    onComplete() // Call the completion handler
                }) {
                    Text("Skip for Now")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .padding(.top, 40)
        }
    }
}

struct ConnectCardView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectCardView(onComplete: {})
    }
}