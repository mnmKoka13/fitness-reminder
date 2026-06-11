import SwiftUI

struct VideoRowView: View {
    let item: VideoItem

    var body: some View {
        HStack(spacing: 12) {
            thumbnailView
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title ?? item.url)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(domain)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var thumbnailView: some View {
        Group {
            if let data = item.thumbnailData, let image = platformImage(from: data) {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: platformIcon)
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGray5))
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var domain: String {
        if item.url.contains("instagram.com") { return "instagram.com" }
        if item.url.contains("youtube.com") || item.url.contains("youtu.be") { return "youtube.com" }
        return URL(string: item.url)?.host ?? item.url
    }

    private var platformIcon: String {
        item.url.contains("instagram.com") ? "camera.fill" : "play.rectangle.fill"
    }

    private func platformImage(from data: Data) -> Image? {
        #if canImport(UIKit)
        return UIImage(data: data).map(Image.init(uiImage:))
        #elseif canImport(AppKit)
        return NSImage(data: data).map(Image.init(nsImage:))
        #else
        return nil
        #endif
    }
}
