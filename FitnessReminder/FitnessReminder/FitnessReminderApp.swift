import SwiftUI

@main
struct FitnessReminderApp: App {
    @State private var videoListViewModel = VideoListViewModel()
    @State private var workoutLogViewModel = WorkoutLogViewModel()
    @State private var isShowingCompletionPopup = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            TabView {
                VideoListView(viewModel: videoListViewModel)
                    .tabItem {
                        Label("動画", systemImage: "play.rectangle")
                    }
                WorkoutLogView(viewModel: workoutLogViewModel)
                    .tabItem {
                        Label("ログ", systemImage: "calendar")
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
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            if videoListViewModel.videoOpenedAt != nil && !workoutLogViewModel.isTodayLogged() {
                isShowingCompletionPopup = true
            }
            videoListViewModel.videoOpenedAt = nil
        }
    }
}
