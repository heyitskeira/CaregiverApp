import Foundation

struct CareTask: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var title: String
    var scheduledAt: Date
    var durationMinutes: Int
    var instructions: String
    var careTeamID: UUID
    var patientID: UUID
    var assigneeIDs: [UUID]
    var status: TaskStatus
    var recurrence: TaskRecurrence
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
        assigneeIDs: [UUID] = [],
        status: TaskStatus? = nil,
        recurrence: TaskRecurrence = .none,
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
        self.assigneeIDs = assigneeIDs
        self.recurrence = recurrence
        self.createdByID = createdByID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.status = status ?? Self.derivedStatus(assigneeIDs: assigneeIDs)
    }

    static func derivedStatus(assigneeIDs: [UUID]) -> TaskStatus {
        assigneeIDs.isEmpty ? .unassigned : .assigned
    }

    func isAssigned(to memberID: UUID) -> Bool {
        assigneeIDs.contains(memberID)
    }
}
