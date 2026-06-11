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

    var isAtLimit: Bool { videoItems.count >= 10 }

    func addVideo(url: String) async {
        guard !isAtLimit else { return }
        guard validator.isValid(url) else {
            addVideoErrorMessage = "Instagram または YouTube の URL を入力してください"
            return
        }
        addVideoErrorMessage = nil
        let newItem = VideoItem(url: url, order: videoItems.count)
        videoItems.append(newItem)
        save()
        isShowingAddVideo = false

        let fetcher = VideoMetadataFetcher()
        if let metadata = await fetcher.fetch(urlString: url),
           let index = videoItems.firstIndex(where: { $0.id == newItem.id }) {
            videoItems[index].title = metadata.title
            videoItems[index].thumbnailData = metadata.thumbnailData
            save()
        }
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
