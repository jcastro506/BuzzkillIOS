import SwiftUI

struct MainTabView: View {
    @Binding var selectedTab: Int

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)

            SetBudgetView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Budget")
                }
                .tag(1)

            PastBudgetsListView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("Past Budgets")
                }
                .tag(3)

            ChatView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
                .tag(2)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    @State static var selectedTab = 0

    static var previews: some View {
        MainTabView(selectedTab: $selectedTab)
    }
} 