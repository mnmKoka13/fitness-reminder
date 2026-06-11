import Testing
import Foundation
@testable import FitnessReminder

struct VideoRepositoryTests {
    private func makeRepository() -> VideoRepository {
        let suiteName = UUID().uuidString
        let defaults = UserDefaults(suiteName: suiteName)!
        return VideoRepository(defaults: defaults)
    }

    @Test func test_load_whenEmpty_returnsEmptyArray() {
        let repo = makeRepository()
        #expect(repo.load().isEmpty)
    }

    @Test func test_saveAndLoad_persistsItems() {
        let repo = makeRepository()
        let item = VideoItem(url: "https://www.youtube.com/watch?v=abc", order: 0)
        repo.save([item])

        let loaded = repo.load()
        #expect(loaded.count == 1)
        #expect(loaded[0].url == item.url)
    }

    @Test func test_load_returnsSortedByOrder() {
        let repo = makeRepository()
        let items = [
            VideoItem(url: "https://youtu.be/c", order: 2),
            VideoItem(url: "https://youtu.be/a", order: 0),
            VideoItem(url: "https://youtu.be/b", order: 1)
        ]
        repo.save(items)

        let loaded = repo.load()
        #expect(loaded.map(\.order) == [0, 1, 2])
    }

    @Test func test_save_overwritesPreviousData() {
        let repo = makeRepository()
        repo.save([VideoItem(url: "https://youtu.be/old", order: 0)])
        repo.save([VideoItem(url: "https://youtu.be/new", order: 0)])

        let loaded = repo.load()
        #expect(loaded.count == 1)
        #expect(loaded[0].url == "https://youtu.be/new")
    }

    @Test func test_save_emptyArray_clearsItems() {
        let repo = makeRepository()
        repo.save([VideoItem(url: "https://youtu.be/abc", order: 0)])
        repo.save([])

        #expect(repo.load().isEmpty)
    }

    @Test func test_load_legacyDataWithoutMetadata_returnsItemsWithNilFields() throws {
        let suiteName = UUID().uuidString
        let defaults = UserDefaults(suiteName: suiteName)!

        // title・thumbnailData が存在しない旧フォーマットの JSON
        let legacyJSON = """
        [{"id":"00000000-0000-0000-0000-000000000001","url":"https://youtu.be/abc","order":0,"createdAt":0}]
        """
        defaults.set(legacyJSON.data(using: .utf8), forKey: "videoItems")

        let repo = VideoRepository(defaults: defaults)
        let loaded = repo.load()

        #expect(loaded.count == 1)
        #expect(loaded[0].url == "https://youtu.be/abc")
        #expect(loaded[0].title == nil)
        #expect(loaded[0].thumbnailData == nil)
    }
}
