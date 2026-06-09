import Foundation

struct CareTask: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var title: String
    var scheduledAt: Date
    var durationMinutes: Int
    var instructions: String
    var careTeamID: UUID
    var patientID: UUID
    var status: TaskStatus
    var recurrenceFrequency: TaskRecurrenceFrequency
    var recurrenceInterval: Int
    var recurrenceUnit: TaskRecurrenceUnit?
    var createdByID: UUID
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        scheduledAt: Date,
        durationMinutes: Int,
        instructions: String = "",
        careTeamID: UUID,
        patientID: UUID,
        status: TaskStatus = .unassigned,
        recurrenceFrequency: TaskRecurrenceFrequency = .none,
        recurrenceInterval: Int = 1,
        recurrenceUnit: TaskRecurrenceUnit? = nil,
        createdByID: UUID,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.scheduledAt = scheduledAt
        self.durationMinutes = durationMinutes
        self.instructions = instructions
        self.careTeamID = careTeamID
        self.patientID = patientID
        self.status = status
        self.recurrenceFrequency = recurrenceFrequency
        self.recurrenceInterval = max(1, recurrenceInterval)
        self.recurrenceUnit = recurrenceUnit
        self.createdByID = createdByID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var hasRecurrence: Bool {
        recurrenceFrequency != .none
    }
}
