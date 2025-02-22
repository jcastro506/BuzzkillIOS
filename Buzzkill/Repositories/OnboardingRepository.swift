import Foundation

class OnboardingRepository: OnboardingRepositoryProtocol {
    static let shared = OnboardingRepository()
    
    private init() {}
    
    // Example method to handle onboarding data
    func fetchOnboardingData() -> [String] {
        // Return the onboarding questions
        return [
            "How much do you usually spend on a night out?",
            "Do you often exceed your budget?",
            "What could you have bought with the money spent on drinks last month?",
            "How often do you buy rounds for friends?",
            "What's your current financial status after a night out?",
            "If your spending habits were a startup, what would it be?"
        ]
    }
} 