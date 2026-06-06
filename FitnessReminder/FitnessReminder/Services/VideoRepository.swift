import Foundation

final class VideoRepository {
    private let key = "videoItems"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [VideoItem] {
        guard let data = defaults.data(forKey: key),
              let items = try? JSONDecoder().decode([VideoItem].self, from: data) else {
            return []
        }
        return items.sorted { $0.order < $1.order }
    }

    func save(_ items: [VideoItem]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: key)
    }
}
