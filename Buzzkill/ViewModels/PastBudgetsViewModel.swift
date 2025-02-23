import Foundation
import Combine
import FirebaseFirestore

class PastBudgetsViewModel: ObservableObject {
    @Published var pastBudgets: [PastBudget] = []
    @Published var isLoading: Bool = false
    private let pastBudgetsRepository: PastBudgetsRepositoryProtocol
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthService, pastBudgetsRepository: PastBudgetsRepositoryProtocol = PastBudgetsRepository.shared) {
        self.authService = authService
        self.pastBudgetsRepository = pastBudgetsRepository
        
        // Wait for the user to be set before fetching past budgets
        authService.onUserSet { [weak self] in
            guard let userId = self?.authService.user?.id else {
                print("User ID not available")
                return
            }
            self?.fetchAllUserPastBudgets(userId: userId)
        }
    }

    // New function to fetch all past budgets for a specific user
    func fetchAllUserPastBudgets(userId: String) {
        isLoading = true
        pastBudgetsRepository.fetchUserPastBudgets(userId: userId) { [weak self] pastBudgets, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("Error fetching user past budgets: \(error.localizedDescription)")
                    return
                }
                
                if let pastBudgets = pastBudgets {
                    // Sort the past budgets by startDate in descending order
                    self?.pastBudgets = pastBudgets.sorted(by: { $0.startDate > $1.startDate })
                    print("Fetched all user past budgets: \(pastBudgets)")
                } else {
                    print("No past budgets found for user")
                }
            }
        }
    }
} 