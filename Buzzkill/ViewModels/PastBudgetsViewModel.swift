import Foundation
import Combine
import FirebaseFirestore

class PastBudgetsViewModel: ObservableObject {
    @Published var pastBudgets: [PastBudget] = []
    @Published var isLoading: Bool = false
    private let pastBudgetsRepository: PastBudgetsRepositoryProtocol
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    private var currentPage: Int = 0
    private let pageSize: Int = 10
    var allDataLoaded: Bool = false

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

    // Updated function to fetch a limited number of past budgets for a specific user
    func fetchAllUserPastBudgets(userId: String, limit: Int = 10) {
        isLoading = true
        currentPage = 0
        allDataLoaded = false
        pastBudgetsRepository.fetchUserPastBudgets(userId: userId) { [weak self] pastBudgets, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("Error fetching user past budgets: \(error.localizedDescription)")
                    return
                }
                
                if let pastBudgets = pastBudgets {
                    // Sort the past budgets by startDate in descending order and limit the results
                    self?.pastBudgets = pastBudgets
                        .sorted(by: { $0.startDate > $1.startDate })
                        .prefix(limit)
                        .map { $0 }
                    self?.allDataLoaded = pastBudgets.count < limit
                    print("Fetched latest \(limit) user past budgets: \(self?.pastBudgets ?? [])")
                } else {
                    print("No past budgets found for user")
                }
            }
        }
    }

    // New function to fetch the next page of past budgets
    func fetchNextPage(userId: String) {
        guard !isLoading && !allDataLoaded else { return }
        isLoading = true
        currentPage += 1
        pastBudgetsRepository.fetchUserPastBudgets(userId: userId) { [weak self] pastBudgets, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("Error fetching user past budgets: \(error.localizedDescription)")
                    return
                }
                
                if let pastBudgets = pastBudgets {
                    // Sort the past budgets by startDate in descending order and append the next page
                    let newBudgets = pastBudgets
                        .sorted(by: { $0.startDate > $1.startDate })
                        .dropFirst(self!.currentPage * self!.pageSize)
                        .prefix(self!.pageSize)
                        .map { $0 }
                    self?.pastBudgets.append(contentsOf: newBudgets)
                    self?.allDataLoaded = newBudgets.count < self!.pageSize
                    print("Fetched next page of user past budgets: \(newBudgets)")
                } else {
                    self?.allDataLoaded = true
                    print("No more past budgets found for user")
                }
            }
        }
    }
} 