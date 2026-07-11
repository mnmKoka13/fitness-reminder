import Foundation
import SwiftUI

@Observable
final class VideoListViewModel {
    var folders: [VideoFolder] = []
    var videoItems: [VideoItem] = []
    var selectedFolderId: UUID? = nil
    var isShowingAddVideo = false
    var isShowingAddFolder = false
    var isShowingSettings = false
    var addVideoErrorMessage: String? = nil
    var addFolderErrorMessage: String? = nil
    var videoOpenedAt: Date? = nil

    private let repository: VideoRepository
    private let folderRepository: VideoFolderRepository
    private let validator = URLValidator.self

    init(repository: VideoRepository = VideoRepository(),
         folderRepository: VideoFolderRepository = VideoFolderRepository()) {
        self.repository = repository
        self.folderRepository = folderRepository
        self.folders = folderRepository.load()
        self.videoItems = repository.load()
        migrateLegacyVideosIfNeeded()
    }

    private func migrateLegacyVideosIfNeeded() {
        guard let defaultFolder = folders.first(where: { $0.isDefault }) else { return }
        var didMigrate = false
        for index in videoItems.indices where videoItems[index].folderId == nil {
            videoItems[index].folderId = defaultFolder.id
            didMigrate = true
        }
        if didMigrate { repository.save(videoItems) }
    }

    var displayedVideoItems: [VideoItem] {
        guard let selectedFolderId else { return videoItems }
        return videoItems.filter { $0.folderId == selectedFolderId }
    }

    func isAtLimit(for folderId: UUID) -> Bool {
        videoItems.filter { $0.folderId == folderId }.count >= 10
    }

    var isAddDisabled: Bool {
        guard let selectedFolderId else { return false }
        return isAtLimit(for: selectedFolderId)
    }

    func addVideo(url: String, folderId: UUID) async {
        guard !isAtLimit(for: folderId) else {
            addVideoErrorMessage = "選択したフォルダは動画が最大10件登録されています"
            return
        }
        guard validator.isValid(url) else {
            addVideoErrorMessage = "Instagram または YouTube の URL を入力してください"
            return
        }
        addVideoErrorMessage = nil
        let newItem = VideoItem(url: url, order: videoItems.count, folderId: folderId)
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
        let idsToDelete = Set(offsets.map { displayedVideoItems[$0].id })
        videoItems.removeAll { idsToDelete.contains($0.id) }
        reorder()
        save()
    }

    func moveVideo(from source: IndexSet, to destination: Int) {
        var reordered = displayedVideoItems
        reordered.move(fromOffsets: source, toOffset: destination)
        let filteredIds = Set(displayedVideoItems.map(\.id))
        var queue = reordered.makeIterator()
        videoItems = videoItems.map { filteredIds.contains($0.id) ? queue.next()! : $0 }
        reorder()
        save()
    }

    func addFolder(name: String) {
        guard let trimmed = validatedFolderName(name) else { return }
        let newFolder = VideoFolder(name: trimmed, order: folders.count)
        folders.append(newFolder)
        folderRepository.save(folders)
        isShowingAddFolder = false
    }

    func renameFolder(_ folder: VideoFolder, to newName: String) {
        guard let trimmed = validatedFolderName(newName),
              let index = folders.firstIndex(where: { $0.id == folder.id }) else { return }
        folders[index].name = trimmed
        folderRepository.save(folders)
    }

    func deleteFolder(_ folder: VideoFolder) {
        guard !folder.isDefault else { return }
        videoItems.removeAll { $0.folderId == folder.id }
        folders.removeAll { $0.id == folder.id }
        if selectedFolderId == folder.id { selectedFolderId = nil }
        repository.save(videoItems)
        folderRepository.save(folders)
    }

    private func validatedFolderName(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            addFolderErrorMessage = "フォルダ名を入力してください"
            return nil
        }
        guard trimmed.count <= 20 else {
            addFolderErrorMessage = "フォルダ名は20文字以内で入力してください"
            return nil
        }
        addFolderErrorMessage = nil
        return trimmed
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
