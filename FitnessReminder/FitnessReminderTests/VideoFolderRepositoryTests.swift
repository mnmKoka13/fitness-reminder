import Testing
import Foundation
@testable import FitnessReminder

struct VideoFolderRepositoryTests {
    private func makeRepository() -> VideoFolderRepository {
        let suiteName = UUID().uuidString
        let defaults = UserDefaults(suiteName: suiteName)!
        return VideoFolderRepository(defaults: defaults)
    }

    @Test func test_load_whenNoSavedData_generatesDefaultFolder() {
        let repo = makeRepository()
        let loaded = repo.load()

        #expect(loaded.count == 1)
        #expect(loaded[0].name == "デフォルト")
        #expect(loaded[0].isDefault == true)
    }

    @Test func test_load_whenSavedDataIsEmptyArray_generatesDefaultFolder() {
        let repo = makeRepository()
        repo.save([])

        let loaded = repo.load()
        #expect(loaded.count == 1)
        #expect(loaded[0].isDefault == true)
    }

    @Test func test_saveAndLoad_persistsFolders() {
        let repo = makeRepository()
        let folder = VideoFolder(name: "胸トレ", order: 0)
        repo.save([folder])

        let loaded = repo.load()
        #expect(loaded.count == 1)
        #expect(loaded[0].name == "胸トレ")
        #expect(loaded[0].id == folder.id)
    }

    @Test func test_load_returnsSortedByOrder() {
        let repo = makeRepository()
        let folders = [
            VideoFolder(name: "c", order: 2),
            VideoFolder(name: "a", order: 0),
            VideoFolder(name: "b", order: 1)
        ]
        repo.save(folders)

        let loaded = repo.load()
        #expect(loaded.map(\.order) == [0, 1, 2])
    }
}
