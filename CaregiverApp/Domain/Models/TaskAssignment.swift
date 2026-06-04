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

    /// Builds audit records for each assignee on a task.
    static func records(
        for task: CareTask,
        assignedByID: UUID,
        assignedAt: Date = .now
    ) -> [TaskAssignment] {
        task.assigneeIDs.map { assigneeID in
            TaskAssignment(
                taskID: task.id,
                assigneeID: assigneeID,
                assignedByID: assignedByID,
                assignedAt: assignedAt
            )
        }
    }
}
