import SwiftUI

@main
struct FitnessReminderApp: App {
    @State private var videoListViewModel = VideoListViewModel()
    @State private var workoutLogViewModel = WorkoutLogViewModel()
    @State private var isShowingCompletionPopup = false
    @State private var isShowingSplash = true
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            if isShowingSplash {
                SplashView { isShowingSplash = false }
            } else {
                TabView {
                    VideoListView(viewModel: videoListViewModel)
                        .tabItem {
                            Label("お気に入り動画一覧", systemImage: "play.rectangle")
                        }
                    WorkoutLogView(viewModel: workoutLogViewModel)
                        .tabItem {
                            Label("運動ログ", systemImage: "calendar")
                        }
                }
                .sheet(isPresented: $isShowingCompletionPopup) {
                    WorkoutCompletionPopup {
                        workoutLogViewModel.logToday()
                        isShowingCompletionPopup = false
                    } onDismiss: {
                        isShowingCompletionPopup = false
                    }
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            if videoListViewModel.videoOpenedAt != nil && !workoutLogViewModel.isTodayLogged() {
                isShowingCompletionPopup = true
            }
            videoListViewModel.videoOpenedAt = nil
        }
    }
}
