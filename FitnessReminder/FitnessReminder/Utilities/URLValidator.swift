import Foundation

enum URLValidator {
    private static let supportedHosts: Set<String> = [
        "instagram.com",
        "www.instagram.com",
        "youtube.com",
        "www.youtube.com",
        "m.youtube.com",
        "youtu.be"
    ]

    static func isValid(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return false
        }
        return supportedHosts.contains(host)
    }
}
