import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentQuestionIndex = 0
    @Published var progress: CGFloat = 0.0
    @Published var isComplete = false
    @Published var selectedAnswers: [Int?]
    @Published var showConnectCardPrompt = false
    @Published var isCardConnected = false

    let questions = [
        "How much money did you lose to 'just one more round' last month?",
        "Be honest: Have you ever checked your bank account the morning after and thought… 'who TF stole my money?'",
        "Your last big night out cost as much as...",
        "How often do you end up buying drinks for 'friends' you just met?",
        "Your liver has a savings account. What's your balance?",
        "If your bar tab had an investment portfolio, how rich would you be?"
    ]

    let answers = [
        ["$0 - I am a responsible adult (Lies.)", "$20 - $50 (I mean, that's just a couple of Ubers home…)", "$50 - $100 (That's like...a full year of Netflix.)", "More than $100 (You could've bought stocks, but no. You bought tequila.)"],
        ["No, I always budget my fun (Sure, buddy.)", "Once or twice, but I like living on the edge.", "Every weekend. My bank statements give me anxiety.", "I don't even check. If I don't see it, it didn't happen."],
        ["A week's worth of groceries. Hope you enjoy ramen.", "A whole year of Amazon Prime. But hey, at least you got bottle service.", "A car payment. Because alcohol is definitely an asset.", "A round-trip flight to another country. But you went to the same bar... again."],
        ["Never. I only pay for myself (and my future financial stability).", "Rarely, but only when I'm already tipsy.", "Often. It's called being a good time.", "Every weekend. I basically fund the bar's rent."],
        ["$500 - $1,000: Healthy-ish.", "$50 - $500: A little rough, but still standing.", "$0 - I drink like I'm on vacation.", "Overdrawn. My liver just sent me a Venmo request."],
        ["A decent savings account. I make smart choices.", "A struggling startup. Some wins, mostly losses.", "I could've been a crypto millionaire. Instead, I bought Fireball shots.", "I own negative assets. Even my past self regrets me."]
    ]

    init() {
        selectedAnswers = Array(repeating: nil, count: questions.count)
    }

    func selectAnswer(at index: Int) {
        selectedAnswers[currentQuestionIndex] = index
    }

    func goToNextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            progress = CGFloat(currentQuestionIndex) / CGFloat(questions.count - 1)
        } else {
            isComplete = true
        }
    }

    func goToPreviousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            progress = CGFloat(currentQuestionIndex) / CGFloat(questions.count - 1)
        }
    }
} 