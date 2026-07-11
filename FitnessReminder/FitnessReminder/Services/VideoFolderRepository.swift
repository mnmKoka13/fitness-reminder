import Foundation

final class VideoFolderRepository {
    private let key = "videoFolders"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [VideoFolder] {
        guard let data = defaults.data(forKey: key),
              let folders = try? JSONDecoder().decode([VideoFolder].self, from: data),
              !folders.isEmpty else {
            let defaultFolder = VideoFolder(name: "デフォルト", order: 0, isDefault: true)
            save([defaultFolder])
            return [defaultFolder]
        }
        return folders.sorted { $0.order < $1.order }
    }

    func save(_ folders: [VideoFolder]) {
        guard let data = try? JSONEncoder().encode(folders) else { return }
        defaults.set(data, forKey: key)
    }
}
