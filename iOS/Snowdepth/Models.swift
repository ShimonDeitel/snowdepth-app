import Foundation

struct SnowdepthEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var date: Date
    var depth: String
    var notes: String
    var notes: String = ""
}
