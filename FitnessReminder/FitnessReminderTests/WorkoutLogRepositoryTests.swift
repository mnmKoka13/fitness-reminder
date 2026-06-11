import Testing
import Foundation
@testable import FitnessReminder

struct WorkoutLogRepositoryTests {
    private func makeRepository() -> WorkoutLogRepository {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        return WorkoutLogRepository(defaults: defaults)
    }

    @Test func test_load_whenEmpty_returnsEmptyLog() {
        let repo = makeRepository()
        #expect(repo.load().loggedDates.isEmpty)
    }

    @Test func test_addDate_savesDate() {
        let repo = makeRepository()
        repo.addDate("2026-06-11")
        #expect(repo.load().loggedDates == ["2026-06-11"])
    }

    @Test func test_addDate_isIdempotent() {
        let repo = makeRepository()
        repo.addDate("2026-06-11")
        repo.addDate("2026-06-11")
        #expect(repo.load().loggedDates.count == 1)
    }

    @Test func test_addDate_multipleDates() {
        let repo = makeRepository()
        repo.addDate("2026-06-10")
        repo.addDate("2026-06-11")
        #expect(repo.load().loggedDates.count == 2)
    }

    @Test func test_removeDate_removesDate() {
        let repo = makeRepository()
        repo.addDate("2026-06-11")
        repo.removeDate("2026-06-11")
        #expect(repo.load().loggedDates.isEmpty)
    }

    @Test func test_removeDate_whenNotExists_doesNothing() {
        let repo = makeRepository()
        repo.removeDate("2026-06-11")
        #expect(repo.load().loggedDates.isEmpty)
    }

    @Test func test_removeDate_onlyRemovesTargetDate() {
        let repo = makeRepository()
        repo.addDate("2026-06-10")
        repo.addDate("2026-06-11")
        repo.removeDate("2026-06-10")
        #expect(repo.load().loggedDates == ["2026-06-11"])
    }
}
