import Foundation

class FriendsViewModel: ObservableObject {
    private let friendsRepository: FriendsRepository
    
    init(friendsRepository: FriendsRepository = .shared) {
        self.friendsRepository = friendsRepository
    }
    
    // Example function to load friends list
    func loadFriendsList() {
        friendsRepository.fetchFriendsList { friends in
            // Handle the fetched friends list
            print("Fetched friends: \(friends)")
        }
    }
    
    // Example function to add a friend
    func addFriend(_ friend: String) {
        friendsRepository.addFriend(friend) { success in
            if success {
                print("Friend added successfully")
            } else {
                print("Failed to add friend")
            }
        }
    }
} 