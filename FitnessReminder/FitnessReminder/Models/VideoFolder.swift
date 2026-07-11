import Foundation

struct VideoFolder: Identifiable, Codable {
    let id: UUID
    var name: String
    var order: Int
    let isDefault: Bool

    init(name: String, order: Int, isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.order = order
        self.isDefault = isDefault
    }
}
