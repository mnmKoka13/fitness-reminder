import Foundation

@Observable
final class WorkoutLogViewModel {
    private let repository: WorkoutLogRepository
    private var loggedDates: Set<String> = []

    var currentMonth: Date
    var dateToDelete: String? = nil
    var isShowingDeleteConfirm = false

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "yyyy年M月"
        return f
    }()

    init(repository: WorkoutLogRepository = WorkoutLogRepository()) {
        self.repository = repository
        self.loggedDates = Set(repository.load().loggedDates)
        let cal = Calendar.current
        self.currentMonth = cal.date(from: cal.dateComponents([.year, .month], from: Date()))!
    }

    // MARK: - 日付ユーティリティ

    func dateString(for date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }

    func isLogged(_ date: Date) -> Bool {
        loggedDates.contains(dateString(for: date))
    }

    func isTodayLogged() -> Bool {
        loggedDates.contains(dateString(for: Date()))
    }

    // MARK: - ログ操作

    func logToday() {
        let today = dateString(for: Date())
        loggedDates.insert(today)
        repository.addDate(today)
    }

    func removeLog(_ dateString: String) {
        loggedDates.remove(dateString)
        repository.removeDate(dateString)
        self.dateToDelete = nil
    }

    // MARK: - カレンダーナビゲーション

    var currentMonthTitle: String {
        Self.monthFormatter.string(from: currentMonth)
    }

    var canGoToPrevious: Bool {
        currentMonth > earliestAllowedMonth
    }

    var canGoToNext: Bool {
        currentMonth < startOfCurrentMonth
    }

    func goToPreviousMonth() {
        guard canGoToPrevious else { return }
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
    }

    func goToNextMonth() {
        guard canGoToNext else { return }
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
    }

    // MARK: - カレンダーグリッド

    var calendarDays: [Date?] {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: currentMonth) else { return [] }

        let weekday = cal.component(.weekday, from: currentMonth)
        let leadingNils: [Date?] = Array(repeating: nil, count: weekday - 1)
        let days: [Date?] = range.map { day in
            cal.date(byAdding: .day, value: day - 1, to: currentMonth)
        }
        return leadingNils + days
    }

    // MARK: - プライベート

    private var startOfCurrentMonth: Date {
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.year, .month], from: Date()))!
    }

    private var earliestAllowedMonth: Date {
        Calendar.current.date(byAdding: .month, value: -2, to: startOfCurrentMonth)!
    }
}
