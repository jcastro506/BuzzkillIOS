import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel = OnboardingViewModel()
    @Binding var isOnboardingComplete: Bool

    var body: some View {
        NavigationStack {
            VStack {
                // Progress Bar
                ProgressView(value: viewModel.progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()

                Spacer()

                // Question
                Text(viewModel.questions[viewModel.currentQuestionIndex])
                    .font(.title)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()

                // Answer Options with Selection Highlight
                ForEach(viewModel.answers[viewModel.currentQuestionIndex].indices, id: \.self) { index in
                    Button(action: {
                        viewModel.selectAnswer(at: index)
                        updateProgress()
                    }) {
                        Text(viewModel.answers[viewModel.currentQuestionIndex][index])
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                viewModel.selectedAnswers[viewModel.currentQuestionIndex] == index
                                    ? Color.cyan.opacity(0.8)
                                    : Color.blue.opacity(0.7)
                            )
                            .cornerRadius(12)
                            .animation(.easeInOut, value: viewModel.selectedAnswers[viewModel.currentQuestionIndex])
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()

                // Navigation Buttons
                HStack {
                    Button(action: {
                        viewModel.goToPreviousQuestion()
                        updateProgress()
                    }) {
                        Text("Previous")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .opacity(viewModel.currentQuestionIndex == 0 ? 0 : 1) // Hide but keep space

                    Spacer() // Ensures even spacing

                    Button(action: {
                        if viewModel.currentQuestionIndex < viewModel.questions.count - 1 {
                            viewModel.goToNextQuestion()
                        } else {
                            isOnboardingComplete = true
                        }
                        updateProgress()
                    }) {
                        Text(viewModel.currentQuestionIndex < viewModel.questions.count - 1 ? "Next" : "Finish")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.cyan, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
                            )
                            .opacity(viewModel.selectedAnswers[viewModel.currentQuestionIndex] == nil ? 0.5 : 1.0) // Visually disable button
                    }
                    .padding(.horizontal, 20)
                    .disabled(viewModel.selectedAnswers[viewModel.currentQuestionIndex] == nil) // Disable if no answer is selected
                }
                .frame(maxWidth: .infinity) // Ensures both buttons are aligned properly

                Spacer()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.gray]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            )
            .onAppear {
                viewModel.progress = 0.0
                viewModel.currentQuestionIndex = 0
                viewModel.isComplete = false
            }
        }
    }

    private func updateProgress() {
        viewModel.progress = Double(viewModel.currentQuestionIndex + 1) / Double(viewModel.questions.count)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isOnboardingComplete: .constant(false))
    }
}
