import Foundation

final class WorkoutLogRepository {
    private let key = "workoutLog"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> WorkoutLog {
        guard let data = defaults.data(forKey: key),
              let log = try? JSONDecoder().decode(WorkoutLog.self, from: data) else {
            return WorkoutLog(loggedDates: [])
        }
        return log
    }

    func addDate(_ dateString: String) {
        var log = load()
        guard !log.loggedDates.contains(dateString) else { return }
        log.loggedDates.append(dateString)
        save(log)
    }

    func removeDate(_ dateString: String) {
        var log = load()
        log.loggedDates.removeAll { $0 == dateString }
        save(log)
    }

    private func save(_ log: WorkoutLog) {
        guard let data = try? JSONEncoder().encode(log) else { return }
        defaults.set(data, forKey: key)
    }
}
