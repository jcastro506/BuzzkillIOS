import Foundation
import Combine

class PastBudgetsViewModel: ObservableObject {
    @Published var pastBudgets: [PastBudget] = []
    @Published var isLoading = false
    private var currentPage = 0
    private let pageSize = 10
    private let pastBudgetsRepository: PastBudgetsRepositoryProtocol

    init(pastBudgetsRepository: PastBudgetsRepositoryProtocol = PastBudgetsRepository.shared) {
        self.pastBudgetsRepository = pastBudgetsRepository
    }

    func loadInitialBudgets() {
        isLoading = true
        pastBudgetsRepository.fetchPastBudgets(page: 0, size: pageSize) { [weak self] budgets in
            self?.pastBudgets = budgets
            self?.isLoading = false
        }
    }

    func loadMoreBudgets() {
        guard !isLoading else { return }
        isLoading = true
        pastBudgetsRepository.fetchPastBudgets(page: currentPage + 1, size: pageSize) { [weak self] newBudgets in
            self?.pastBudgets.append(contentsOf: newBudgets)
            self?.currentPage += 1
            self?.isLoading = false
        }
    }
} 