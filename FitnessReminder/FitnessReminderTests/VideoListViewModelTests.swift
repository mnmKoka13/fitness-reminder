import Testing
import Foundation
@testable import FitnessReminder

struct VideoListViewModelTests {
    private func makeViewModel(
        videoDefaults: UserDefaults = UserDefaults(suiteName: UUID().uuidString)!,
        folderDefaults: UserDefaults = UserDefaults(suiteName: UUID().uuidString)!
    ) -> VideoListViewModel {
        VideoListViewModel(
            repository: VideoRepository(defaults: videoDefaults),
            folderRepository: VideoFolderRepository(defaults: folderDefaults)
        )
    }

    // MARK: - 移行処理

    @Test func test_init_migratesLegacyVideosToDefaultFolder() {
        let videoDefaults = UserDefaults(suiteName: UUID().uuidString)!
        let folderDefaults = UserDefaults(suiteName: UUID().uuidString)!

        var legacyItem = VideoItem(url: "https://youtu.be/abc", order: 0, folderId: UUID())
        legacyItem.folderId = nil
        VideoRepository(defaults: videoDefaults).save([legacyItem])

        let vm = makeViewModel(videoDefaults: videoDefaults, folderDefaults: folderDefaults)

        let defaultFolder = vm.folders.first { $0.isDefault }
        #expect(defaultFolder != nil)
        #expect(vm.videoItems[0].folderId == defaultFolder?.id)

        let reloaded = VideoRepository(defaults: videoDefaults).load()
        #expect(reloaded[0].folderId == defaultFolder?.id)
    }

    @Test func test_init_doesNotDeleteVideosExceedingLimitAfterMigration() {
        let videoDefaults = UserDefaults(suiteName: UUID().uuidString)!
        let folderDefaults = UserDefaults(suiteName: UUID().uuidString)!

        let legacyItems = (0..<12).map { index -> VideoItem in
            var item = VideoItem(url: "https://youtu.be/\(index)", order: index, folderId: UUID())
            item.folderId = nil
            return item
        }
        VideoRepository(defaults: videoDefaults).save(legacyItems)

        let vm = makeViewModel(videoDefaults: videoDefaults, folderDefaults: folderDefaults)
        #expect(vm.videoItems.count == 12)
    }

    // MARK: - フィルタリング

    @Test func test_displayedVideoItems_allTab_returnsAllItems() {
        let vm = makeViewModel()
        vm.addFolder(name: "胸トレ")
        let folder = vm.folders.last!
        vm.videoItems = [VideoItem(url: "https://youtu.be/a", order: 0, folderId: folder.id)]
        #expect(vm.displayedVideoItems.count == 1)
    }

    @Test func test_displayedVideoItems_specificFolder_filtersByFolder() {
        let vm = makeViewModel()
        vm.addFolder(name: "胸トレ")
        let folderA = vm.folders.first { $0.isDefault }!
        let folderB = vm.folders.last!
        vm.videoItems = [
            VideoItem(url: "https://youtu.be/a", order: 0, folderId: folderA.id),
            VideoItem(url: "https://youtu.be/b", order: 1, folderId: folderB.id)
        ]
        vm.selectedFolderId = folderB.id
        #expect(vm.displayedVideoItems.map(\.url) == ["https://youtu.be/b"])
    }

    // MARK: - フォルダ単位の上限チェック

    @Test func test_isAtLimit_countsOnlyTargetFolder() {
        let vm = makeViewModel()
        let defaultFolder = vm.folders.first { $0.isDefault }!
        vm.addFolder(name: "胸トレ")
        let otherFolder = vm.folders.last!

        vm.videoItems = (0..<10).map { VideoItem(url: "https://youtu.be/\($0)", order: $0, folderId: defaultFolder.id) }

        #expect(vm.isAtLimit(for: defaultFolder.id) == true)
        #expect(vm.isAtLimit(for: otherFolder.id) == false)
    }

    @Test func test_isAddDisabled_allTabSelected_isAlwaysFalse() {
        let vm = makeViewModel()
        let defaultFolder = vm.folders.first { $0.isDefault }!
        vm.videoItems = (0..<10).map { VideoItem(url: "https://youtu.be/\($0)", order: $0, folderId: defaultFolder.id) }
        vm.selectedFolderId = nil
        #expect(vm.isAddDisabled == false)
    }

    @Test func test_isAddDisabled_folderAtLimitSelected_isTrue() {
        let vm = makeViewModel()
        let defaultFolder = vm.folders.first { $0.isDefault }!
        vm.videoItems = (0..<10).map { VideoItem(url: "https://youtu.be/\($0)", order: $0, folderId: defaultFolder.id) }
        vm.selectedFolderId = defaultFolder.id
        #expect(vm.isAddDisabled == true)
    }

    // MARK: - フォルダCRUD

    @Test func test_addFolder_addsNewFolderWithTrimmedName() {
        let vm = makeViewModel()
        vm.addFolder(name: "  胸トレ  ")
        #expect(vm.folders.last?.name == "胸トレ")
        #expect(vm.isShowingAddFolder == false)
    }

    @Test func test_addFolder_emptyName_setsErrorAndDoesNotAdd() {
        let vm = makeViewModel()
        let countBefore = vm.folders.count
        vm.addFolder(name: "   ")
        #expect(vm.folders.count == countBefore)
        #expect(vm.addFolderErrorMessage != nil)
    }

    @Test func test_addFolder_tooLongName_setsErrorAndDoesNotAdd() {
        let vm = makeViewModel()
        let countBefore = vm.folders.count
        vm.addFolder(name: String(repeating: "a", count: 21))
        #expect(vm.folders.count == countBefore)
        #expect(vm.addFolderErrorMessage != nil)
    }

    @Test func test_renameFolder_updatesName() {
        let vm = makeViewModel()
        vm.addFolder(name: "胸トレ")
        let folder = vm.folders.last!
        vm.renameFolder(folder, to: "背中トレ")
        #expect(vm.folders.last?.name == "背中トレ")
    }

    @Test func test_deleteFolder_defaultFolder_doesNothing() {
        let vm = makeViewModel()
        let defaultFolder = vm.folders.first { $0.isDefault }!
        vm.deleteFolder(defaultFolder)
        #expect(vm.folders.contains { $0.id == defaultFolder.id })
    }

    @Test func test_deleteFolder_removesFolderAndItsVideosAndSwitchesToAllTab() {
        let vm = makeViewModel()
        vm.addFolder(name: "胸トレ")
        let folder = vm.folders.last!
        vm.videoItems = [VideoItem(url: "https://youtu.be/a", order: 0, folderId: folder.id)]
        vm.selectedFolderId = folder.id

        vm.deleteFolder(folder)

        #expect(!vm.folders.contains { $0.id == folder.id })
        #expect(vm.videoItems.isEmpty)
        #expect(vm.selectedFolderId == nil)
    }

    // MARK: - フォルダ単位の並び替え

    @Test func test_moveVideo_onlyReordersWithinSelectedFolder() {
        let vm = makeViewModel()
        let defaultFolder = vm.folders.first { $0.isDefault }!
        vm.addFolder(name: "胸トレ")
        let otherFolder = vm.folders.last!

        vm.videoItems = [
            VideoItem(url: "https://youtu.be/other-a", order: 0, folderId: otherFolder.id),
            VideoItem(url: "https://youtu.be/default-a", order: 1, folderId: defaultFolder.id),
            VideoItem(url: "https://youtu.be/default-b", order: 2, folderId: defaultFolder.id),
            VideoItem(url: "https://youtu.be/other-b", order: 3, folderId: otherFolder.id)
        ]
        vm.selectedFolderId = defaultFolder.id

        vm.moveVideo(from: IndexSet(integer: 1), to: 0)

        #expect(vm.videoItems.filter { $0.folderId == otherFolder.id }.map(\.url) == ["https://youtu.be/other-a", "https://youtu.be/other-b"])
        #expect(vm.displayedVideoItems.map(\.url) == ["https://youtu.be/default-b", "https://youtu.be/default-a"])
    }
}
