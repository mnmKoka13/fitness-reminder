import Testing
import Foundation
@testable import FitnessReminder

struct WorkoutLogViewModelTests {
    private func makeViewModel() -> WorkoutLogViewModel {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        return WorkoutLogViewModel(repository: WorkoutLogRepository(defaults: defaults))
    }

    @Test func test_logToday_marksAsLogged() {
        let vm = makeViewModel()
        vm.logToday()
        #expect(vm.isTodayLogged())
    }

    @Test func test_logToday_isIdempotent() {
        let vm = makeViewModel()
        vm.logToday()
        vm.logToday()
        #expect(vm.isTodayLogged())
    }

    @Test func test_removeLog_unmarksDate() {
        let vm = makeViewModel()
        vm.logToday()
        let todayString = vm.dateString(for: Date())
        vm.removeLog(todayString)
        #expect(!vm.isTodayLogged())
    }

    @Test func test_removeLog_clearsDeletionState() {
        let vm = makeViewModel()
        vm.logToday()
        let todayString = vm.dateString(for: Date())
        vm.dateToDelete = todayString
        vm.removeLog(todayString)
        #expect(vm.dateToDelete == nil)
    }

    @Test func test_calendarDays_containsAllDaysOfMonth() {
        let vm = makeViewModel()
        let cal = Calendar.current
        let expected = cal.range(of: .day, in: .month, for: vm.currentMonth)!.count
        let actual = vm.calendarDays.compactMap { $0 }.count
        #expect(actual == expected)
    }

    @Test func test_calendarDays_leadingNilsMatchFirstWeekday() {
        let vm = makeViewModel()
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: vm.currentMonth)
        let leadingNilCount = vm.calendarDays.prefix(while: { $0 == nil }).count
        #expect(leadingNilCount == weekday - 1)
    }

    @Test func test_goToPreviousMonth_decrementsMonth() {
        let vm = makeViewModel()
        let before = vm.currentMonth
        vm.goToPreviousMonth()
        let cal = Calendar.current
        let diff = cal.dateComponents([.month], from: vm.currentMonth, to: before).month
        #expect(diff == 1)
    }

    @Test func test_goToNextMonth_afterGoingBack() {
        let vm = makeViewModel()
        vm.goToPreviousMonth()
        #expect(vm.canGoToNext)
        vm.goToNextMonth()
        #expect(!vm.canGoToNext)
    }

    @Test func test_canGoToPrevious_falseAt3MonthsBack() {
        let vm = makeViewModel()
        vm.goToPreviousMonth()
        vm.goToPreviousMonth()
        #expect(!vm.canGoToPrevious)
    }

    @Test func test_goToPreviousMonth_doesNotExceedLimit() {
        let vm = makeViewModel()
        vm.goToPreviousMonth()
        vm.goToPreviousMonth()
        vm.goToPreviousMonth()  // 上限を超えようとする
        let cal = Calendar.current
        let startOfCurrent = cal.date(from: cal.dateComponents([.year, .month], from: Date()))!
        let earliest = cal.date(byAdding: .month, value: -2, to: startOfCurrent)!
        #expect(vm.currentMonth == earliest)
    }
}
