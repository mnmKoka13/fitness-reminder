import Foundation

struct VideoItem: Identifiable, Codable {
    let id: UUID
    var url: String
    var order: Int
    let createdAt: Date
    var title: String?
    var thumbnailData: Data?

    init(url: String, order: Int) {
        self.id = UUID()
        self.url = url
        self.order = order
        self.createdAt = Date()
    }
}
