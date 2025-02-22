import Foundation

class FriendsRepository {
    // Singleton instance
    static let shared = FriendsRepository()
    
    private init() {
        // Private initializer to ensure only one instance is created
    }
    
    // Example function to fetch friends list
    func fetchFriendsList(completion: @escaping ([String]) -> Void) {
        // Simulate fetching friends from a data source
        let friends = ["Alice", "Bob", "Charlie"]
        completion(friends)
    }
    
    // Example function to add a friend
    func addFriend(_ friend: String, completion: @escaping (Bool) -> Void) {
        // Simulate adding a friend
        print("Adding friend: \(friend)")
        completion(true)
    }
} 