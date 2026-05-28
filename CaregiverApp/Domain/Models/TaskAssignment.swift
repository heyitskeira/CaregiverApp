import Foundation

struct TaskAssignment: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    let taskID: UUID
    let assigneeID: UUID
    let assignedByID: UUID
    let assignedAt: Date

    init(
        id: UUID = UUID(),
        taskID: UUID,
        assigneeID: UUID,
        assignedByID: UUID,
        assignedAt: Date = .now
    ) {
        self.id = id
        self.taskID = taskID
        self.assigneeID = assigneeID
        self.assignedByID = assignedByID
        self.assignedAt = assignedAt
    }
}
