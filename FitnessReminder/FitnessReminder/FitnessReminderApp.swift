//
//  FitnessReminderApp.swift
//  FitnessReminder
//
//  Created by 小門真愛 on 2026/06/06.
//

import SwiftUI

@main
struct FitnessReminderApp: App {
    @State private var videoListViewModel = VideoListViewModel()

    var body: some Scene {
        WindowGroup {
            VideoListView(viewModel: videoListViewModel)
        }
    }
}
