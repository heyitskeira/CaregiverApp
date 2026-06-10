import Foundation

/// Matches the Supabase `recurrence_frequency` enum type.
enum TaskRecurrenceFrequency: String, Codable, Sendable, CaseIterable {
    case none
    case daily
    case weekly
    case monthly
    case yearly
    case custom
}

/// Matches the Supabase `recurrence_unit` enum type.
enum TaskRecurrenceUnit: String, Codable, Sendable, CaseIterable {
    case days
    case weeks
    case months
    case years
}
