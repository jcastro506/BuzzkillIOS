import SwiftUI

struct ProfileView: View {
    @State private var userName: String = "Dakota Castro"
    @State private var email: String = "dakota@example.com"
    @State private var profileImage: Image? = Image(systemName: "person.circle.fill")
    @State private var totalSpent: Double = 520.75
    @State private var avgSpentPerNight: Double = 43.39
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Centered Profile Section
                    VStack {
                        profileImage?
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.6), lineWidth: 2))
                            .onTapGesture {
                                // TODO: Add image picker functionality
                            }
                        
                        // User Info
                        VStack(spacing: 4) {
                            Text(userName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    Divider()
                        .background(Color.gray.opacity(0.6))
                        .padding(.horizontal)
                    
                    // Budgeting Stats
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Total Spent")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("$\(String(format: "%.2f", totalSpent))")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("Avg Per Night")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("$\(String(format: "%.2f", avgSpentPerNight))")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.6))
                        .padding(.horizontal)
                    
                    // Settings and Preferences
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Settings")
                            .font(.headline)
                            .foregroundColor(.white)
                        Button("Notification Preferences") {
                            // TODO: Implement notification preferences
                        }
                        .foregroundColor(.blue)
                        
                        Button("Account Security") {
                            // TODO: Implement account security settings
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .background(Color.gray.opacity(0.6))
                        .padding(.horizontal)
                    
                    // Help and Support
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Help & Support")
                            .font(.headline)
                            .foregroundColor(.white)
                        Button("FAQs") {
                            // TODO: Implement FAQs
                        }
                        .foregroundColor(.blue)
                        
                        Button("Contact Support") {
                            // TODO: Implement contact support
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .background(Color.gray.opacity(0.6))
                        .padding(.horizontal)
                    
                    // Legal
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Legal")
                            .font(.headline)
                            .foregroundColor(.white)
                        Button("Terms of Service") {
                            // TODO: Implement terms of service
                        }
                        .foregroundColor(.blue)
                        
                        Button("Privacy Policy") {
                            // TODO: Implement privacy policy
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Logout Button
                    Button(action: {
                        // TODO: Implement logout functionality
                    }) {
                        Text("Log Out")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(color: Color.blue.opacity(0.6), radius: 10, x: 0, y: 5)
                            .padding(.horizontal)
                    }
                    
                    // Delete Account Button
                    Button(action: {
                        // TODO: Implement delete account functionality
                    }) {
                        Text("Delete Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                            .padding(.horizontal)
                    }
                }
                .padding()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .preferredColorScheme(.dark)
    }
}
