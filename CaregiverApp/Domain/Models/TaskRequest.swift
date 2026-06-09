import Foundation

enum TaskRequestStatus: String, Codable, Sendable, CaseIterable {
    case pending
    case accepted
    case declined
}

struct TaskRequest: Identifiable, Hashable, Codable, Sendable { // / A care-group member volunteering to take an unassigned task (Inbox flow).
    let id: UUID
    let taskID: UUID
    let requesterID: UUID
    var status: TaskRequestStatus
    let createdAt: Date

    init(
        id: UUID = UUID(),
        taskID: UUID,
        requesterID: UUID,
        status: TaskRequestStatus = .pending,
        createdAt: Date = .now
    ) {
        self.id = id
        self.taskID = taskID
        self.requesterID = requesterID
        self.status = status
        self.createdAt = createdAt
    }
}
