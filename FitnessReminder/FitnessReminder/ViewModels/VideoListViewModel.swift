import Foundation
import SwiftUI

@Observable
final class VideoListViewModel {
    var videoItems: [VideoItem] = []
    var isShowingAddVideo = false
    var isShowingSettings = false
    var addVideoErrorMessage: String? = nil

    private let repository: VideoRepository
    private let validator = URLValidator.self

    init(repository: VideoRepository = VideoRepository()) {
        self.repository = repository
        self.videoItems = repository.load()
    }

    func addVideo(url: String) {
        guard validator.isValid(url) else {
            addVideoErrorMessage = "Instagram または YouTube の URL を入力してください"
            return
        }
        addVideoErrorMessage = nil
        let newItem = VideoItem(url: url, order: videoItems.count)
        videoItems.append(newItem)
        save()
        isShowingAddVideo = false
    }

    func deleteVideo(at offsets: IndexSet) {
        videoItems.remove(atOffsets: offsets)
        reorder()
        save()
    }

    func moveVideo(from source: IndexSet, to destination: Int) {
        videoItems.move(fromOffsets: source, toOffset: destination)
        reorder()
        save()
    }

    private func reorder() {
        for index in videoItems.indices {
            videoItems[index].order = index
        }
    }

    private func save() {
        repository.save(videoItems)
    }
}
