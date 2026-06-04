import Foundation

enum TaskRecurrenceFrequency: String, Codable, Sendable, CaseIterable {
    case none
    case daily
    case weekly
    case monthly
    case yearly
    case custom
}

enum TaskRecurrenceUnit: String, Codable, Sendable, CaseIterable {
    case days
    case weeks
    case months
    case years
}

struct TaskRecurrence: Hashable, Codable, Sendable {
    var frequency: TaskRecurrenceFrequency
    var interval: Int
    var unit: TaskRecurrenceUnit?

    init(
        frequency: TaskRecurrenceFrequency = .none,
        interval: Int = 1,
        unit: TaskRecurrenceUnit? = nil
    ) {
        self.frequency = frequency
        self.interval = max(1, interval)
        self.unit = unit
    }

    static let none = TaskRecurrence()

    var repeats: Bool {
        frequency != .none
    }
}
