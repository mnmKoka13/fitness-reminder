import UserNotifications

final class NotificationService {
    private let notificationID = "dailyFitnessReminder"
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    func isAuthorized() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    func schedule(hour: Int, minute: Int) async {
        center.removePendingNotificationRequests(withIdentifiers: [notificationID])

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = "運動の時間です 💪"
        content.body = "今日も動画を見ながら運動しよう！"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: notificationID,
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }
}
