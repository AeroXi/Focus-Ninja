import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            FocusView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("专注")
                }
            
            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("历史记录")
                }
            
            LeaderboardView()
                .tabItem {
                    Image(systemName: "list.number")
                    Text("排行榜")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("设置")
                }
        }
    }
}
