import Foundation

struct AppSettings: Codable {
    var notificationHour: Int
    var notificationMinute: Int

    static let `default` = AppSettings(notificationHour: 7, notificationMinute: 0)
}
