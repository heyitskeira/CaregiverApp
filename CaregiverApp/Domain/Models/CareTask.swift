import Foundation

struct CareTask: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var title: String
    var scheduledAt: Date
    var durationMinutes: Int
    var instructions: String
    var patientID: UUID
    var assigneeID: UUID?
    var status: TaskStatus

    init(
        id: UUID = UUID(),
        title: String,
        scheduledAt: Date,
        durationMinutes: Int,
        instructions: String = "",
        patientID: UUID,
        assigneeID: UUID? = nil,
        status: TaskStatus = .unassigned
    ) {
        self.id = id
        self.title = title
        self.scheduledAt = scheduledAt
        self.durationMinutes = durationMinutes
        self.instructions = instructions
        self.patientID = patientID
        self.assigneeID = assigneeID
        self.status = status
    }
}
