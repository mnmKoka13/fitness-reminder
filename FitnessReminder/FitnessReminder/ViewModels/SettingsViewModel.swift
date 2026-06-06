import Foundation

@Observable
final class SettingsViewModel {
    var notificationHour: Int
    var notificationMinute: Int
    var isAuthorized = false

    private let notificationService: NotificationService
    private let defaultsKey = "appSettings"

    init(notificationService: NotificationService = NotificationService()) {
        self.notificationService = notificationService
        let settings = Self.loadSettings()
        self.notificationHour = settings.notificationHour
        self.notificationMinute = settings.notificationMinute
    }

    func onAppear() async {
        isAuthorized = await notificationService.isAuthorized()
    }

    func saveSettings() async {
        let settings = AppSettings(
            notificationHour: notificationHour,
            notificationMinute: notificationMinute
        )
        Self.persistSettings(settings)
        await notificationService.schedule(hour: notificationHour, minute: notificationMinute)
        isAuthorized = await notificationService.isAuthorized()
    }

    func requestAuthorization() async {
        isAuthorized = await notificationService.requestAuthorization()
        if isAuthorized {
            await notificationService.schedule(hour: notificationHour, minute: notificationMinute)
        }
    }

    private static func loadSettings() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: "appSettings"),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return .default
        }
        return settings
    }

    private static func persistSettings(_ settings: AppSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: "appSettings")
    }
}
