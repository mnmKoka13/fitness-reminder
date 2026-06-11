import Foundation

struct VideoMetadata {
    let title: String
    let thumbnailData: Data?
}

final class VideoMetadataFetcher {
    func fetch(urlString: String) async -> VideoMetadata? {
        if urlString.contains("youtube.com") || urlString.contains("youtu.be") {
            return await fetchYouTube(urlString: urlString)
        } else if urlString.contains("instagram.com") {
            return await fetchInstagram(urlString: urlString)
        }
        return nil
    }

    private func fetchYouTube(urlString: String) async -> VideoMetadata? {
        guard let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let apiURL = URL(string: "https://www.youtube.com/oembed?url=\(encoded)&format=json"),
              let (data, _) = try? await URLSession.shared.data(from: apiURL),
              let oembed = try? JSONDecoder().decode(YouTubeOEmbed.self, from: data) else {
            return nil
        }
        let thumbnailData = await downloadImage(urlString: oembed.thumbnailURL)
        return VideoMetadata(title: decodeHTMLEntities(oembed.title), thumbnailData: thumbnailData)
    }

    private func fetchInstagram(urlString: String) async -> VideoMetadata? {
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let html = String(data: data, encoding: .utf8),
              let rawTitle = ogpValue(html: html, property: "og:title") else {
            return nil
        }
        var thumbnailData: Data?
        if let imageURL = ogpValue(html: html, property: "og:image") {
            thumbnailData = await downloadImage(urlString: imageURL)
        }
        return VideoMetadata(title: decodeHTMLEntities(rawTitle), thumbnailData: thumbnailData)
    }

    private func downloadImage(urlString: String) async -> Data? {
        guard let url = URL(string: urlString) else { return nil }
        return try? await URLSession.shared.data(from: url).0
    }

    private func decodeHTMLEntities(_ string: String) -> String {
        guard string.contains("&") else { return string }
        var result = string
        for (entity, char) in [("&amp;", "&"), ("&lt;", "<"), ("&gt;", ">"), ("&quot;", "\""), ("&#39;", "'"), ("&apos;", "'")] {
            result = result.replacingOccurrences(of: entity, with: char)
        }
        guard let regex = try? NSRegularExpression(pattern: "&#(?:x([0-9a-fA-F]+)|(\\d+));") else { return result }
        let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
        for match in matches.reversed() {
            guard let range = Range(match.range, in: result) else { continue }
            let codePoint: UInt32?
            if let hexRange = Range(match.range(at: 1), in: result) {
                codePoint = UInt32(result[hexRange], radix: 16)
            } else if let decRange = Range(match.range(at: 2), in: result) {
                codePoint = UInt32(result[decRange])
            } else {
                codePoint = nil
            }
            if let cp = codePoint, let scalar = Unicode.Scalar(cp) {
                result.replaceSubrange(range, with: String(scalar))
            }
        }
        return result
    }

    private func ogpValue(html: String, property: String) -> String? {
        let escaped = NSRegularExpression.escapedPattern(for: property)
        let patterns = [
            "property=[\"']\(escaped)[\"'][^>]+content=[\"']([^\"']+)[\"']",
            "content=[\"']([^\"']+)[\"'][^>]+property=[\"']\(escaped)[\"']"
        ]
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
                  let range = Range(match.range(at: 1), in: html) else { continue }
            return String(html[range])
        }
        return nil
    }
}

private struct YouTubeOEmbed: Decodable {
    let title: String
    let thumbnailURL: String

    enum CodingKeys: String, CodingKey {
        case title
        case thumbnailURL = "thumbnail_url"
    }
}
