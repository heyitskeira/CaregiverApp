import Foundation

enum TaskStatus: String, Codable, Sendable, CaseIterable {
    case unassigned
    case assigned
    case completed
}
