import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var userName: String = "Unknown User"
    @Published var email: String = "Unknown Email"
    @Published var totalSpent: Double = 0.0
    
    private var authService: AuthService
    private var profileRepository: ProfileRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private let setupBudgetRepository: SetupBudgetRepository

    init(authService: AuthService, firestoreManager: FirestoreManager = FirestoreManager.shared) {
        self.authService = authService
        self.profileRepository = ProfileRepository(firestoreManager: firestoreManager)
        self.setupBudgetRepository = SetupBudgetRepository(firestoreManager: firestoreManager)
        bindUserData()
    }
    
    private func bindUserData() {
        profileRepository.bindUserData(authService: authService)
            .sink { [weak self] user in
                self?.userName = user.userName
                self?.email = user.email
                self?.totalSpent = user.totalAmountSpent
                print("User data updated: \(user.userName), \(user.email), Total Spent: \(user.totalAmountSpent), Created At: \(user.createdAt), Total Amount Spent: \(user.totalAmountSpent), Total Budgets Set: \(user.totalBudgetsSet)")
            }
            .store(in: &cancellables)
    }
    
    func signOut() {
        do {
            try authService.signOut()
            // Handle successful sign-out, e.g., notify the view
            print("User signed out successfully")
        } catch {
            // Handle sign-out error, e.g., show an alert
            print("Sign out failed: \(error.localizedDescription)")
        }
    }
    
    func loadUserProfile(userId: String) async {
        do {
            let user = try await profileRepository.fetchUserProfile(userId: userId)
            self.userName = user.userName
            self.email = user.email
            self.totalSpent = user.totalAmountSpent
            print("Loaded user profile: \(user.userName), \(user.email), Total Spent: \(user.totalAmountSpent), Created At: \(user.createdAt)")
        } catch {
            print("Failed to load user profile: \(error.localizedDescription)")
        }
    }
} 