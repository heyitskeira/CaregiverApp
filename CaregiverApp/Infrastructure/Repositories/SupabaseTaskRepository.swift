import Foundation
import Supabase

@MainActor
final class SupabaseTaskRepository: TaskRepository {
    private let careTeamID: UUID
    private let currentUserID: UUID

    init(careTeamID: UUID, currentUserID: UUID) {
        self.careTeamID = careTeamID
        self.currentUserID = currentUserID
    }

    // MARK: - Tasks

    func fetchAllTasks() async throws -> [CareTask] {
        let rows: [DBTaskRow] = try await supabase
            .from("care_tasks")
            .select()
            .eq("care_team_id", value: careTeamID)
            .order("scheduled_at")
            .execute()
            .value
        return rows.map { $0.toDomain() }
    }

    func fetchTasks(assigneeID: UUID) async throws -> [CareTask] {
        // Join through task_assignees to get tasks for a specific contact
        struct AssigneeTaskID: Codable {
            let taskID: UUID
            enum CodingKeys: String, CodingKey { case taskID = "task_id" }
        }
        let assigneeRows: [AssigneeTaskID] = try await supabase
            .from("task_assignees")
            .select("task_id")
            .eq("assignee_id", value: assigneeID)
            .execute()
            .value
        let taskIDs = assigneeRows.map { $0.taskID }
        guard !taskIDs.isEmpty else { return [] }
        let rows: [DBTaskRow] = try await supabase
            .from("care_tasks")
            .select()
            .in("id", values: taskIDs)
            .order("scheduled_at")
            .execute()
            .value
        return rows.map { $0.toDomain() }
    }

    func saveTask(_ task: CareTask) async throws {
        try await supabase
            .from("care_tasks")
            .upsert(TaskPayload(from: task, careTeamID: careTeamID))
            .execute()
    }

    func updateTask(_ task: CareTask) async throws {
        try await supabase
            .from("care_tasks")
            .update(TaskUpdatePayload(from: task))
            .eq("id", value: task.id)
            .execute()
    }

    func deleteTask(id: UUID) async throws {
        try await supabase
            .from("care_tasks")
            .delete()
            .eq("id", value: id)
            .execute()
        // Cascade in DB handles task_assignees, task_assignments, task_requests
    }

    // MARK: - Assignments

    func fetchAssignments(taskID: UUID) async throws -> [TaskAssignment] {
        let rows: [DBAssignmentRow] = try await supabase
            .from("task_assignments")
            .select()
            .eq("task_id", value: taskID)
            .execute()
            .value
        return rows.map { $0.toDomain() }
    }

    func fetchAssignments(assigneeID: UUID) async throws -> [TaskAssignment] {
        let rows: [DBAssignmentRow] = try await supabase
            .from("task_assignments")
            .select()
            .eq("assignee_id", value: assigneeID)
            .execute()
            .value
        return rows.map { $0.toDomain() }
    }

    func addAssignment(_ assignment: TaskAssignment) async throws {
        // Upsert into junction table (idempotent)
        try await supabase
            .from("task_assignees")
            .upsert([
                "task_id": assignment.taskID.uuidString,
                "assignee_id": assignment.assigneeID.uuidString
            ])
            .execute()
        // Write audit row
        try await supabase
            .from("task_assignments")
            .insert([
                "id": assignment.id.uuidString,
                "task_id": assignment.taskID.uuidString,
                "assignee_id": assignment.assigneeID.uuidString,
                "assigned_by_id": assignment.assignedByID.uuidString
            ])
            .execute()
        // Update task status → assigned
        try await supabase
            .from("care_tasks")
            .update(["status": TaskStatus.assigned.rawValue])
            .eq("id", value: assignment.taskID)
            .execute()
    }

    func removeAssignment(taskID: UUID, assigneeID: UUID) async throws {
        try await supabase
            .from("task_assignees")
            .delete()
            .eq("task_id", value: taskID)
            .eq("assignee_id", value: assigneeID)
            .execute()
    }

    // MARK: - Requests

    func fetchPendingRequests(forUser userID: UUID) async throws -> [TaskRequest] {
        let rows: [DBRequestRow] = try await supabase
            .from("task_requests")
            .select()
            .eq("requester_id", value: userID)
            .eq("status", value: TaskRequestStatus.pending.rawValue)
            .execute()
            .value
        return rows.map { $0.toDomain() }
    }

    func fetchAllPendingRequests() async throws -> [TaskRequest] {
        // Fetch requests for tasks in this team
        struct RequestWithTask: Codable {
            let id: UUID
            let taskID: UUID
            let requesterID: UUID
            let status: TaskRequestStatus
            let createdAt: Date
            enum CodingKeys: String, CodingKey {
                case id
                case taskID = "task_id"
                case requesterID = "requester_id"
                case status
                case createdAt = "created_at"
            }
        }
        let rows: [RequestWithTask] = try await supabase
            .from("task_requests")
            .select("*, care_tasks!inner(care_team_id)")
            .eq("care_tasks.care_team_id", value: careTeamID)
            .eq("status", value: TaskRequestStatus.pending.rawValue)
            .execute()
            .value
        return rows.map {
            TaskRequest(id: $0.id, taskID: $0.taskID, requesterID: $0.requesterID,
                       status: $0.status, createdAt: $0.createdAt)
        }
    }

    func createRequest(_ request: TaskRequest) async throws {
        try await supabase
            .from("task_requests")
            .upsert([
                "id": request.id.uuidString,
                "task_id": request.taskID.uuidString,
                "requester_id": request.requesterID.uuidString,
                "status": request.status.rawValue
            ])
            .execute()
    }

    func updateRequestStatus(id: UUID, status: TaskRequestStatus) async throws {
        try await supabase
            .from("task_requests")
            .update(["status": status.rawValue])
            .eq("id", value: id)
            .execute()
    }
}

// MARK: - Encodable payloads

private struct TaskPayload: Encodable {
    let id: UUID
    let careTeamID: UUID
    let patientID: UUID
    let title: String
    let scheduledAt: Date
    let durationMinutes: Int
    let instructions: String
    let status: String
    let recurrenceFrequency: String
    let recurrenceInterval: Int
    let recurrenceUnit: String?
    let createdByID: UUID

    enum CodingKeys: String, CodingKey {
        case id
        case careTeamID = "care_team_id"
        case patientID = "patient_id"
        case title
        case scheduledAt = "scheduled_at"
        case durationMinutes = "duration_minutes"
        case instructions, status
        case recurrenceFrequency = "recurrence_frequency"
        case recurrenceInterval = "recurrence_interval"
        case recurrenceUnit = "recurrence_unit"
        case createdByID = "created_by_id"
    }

    init(from task: CareTask, careTeamID: UUID) {
        id = task.id
        self.careTeamID = careTeamID
        patientID = task.patientID
        title = task.title
        scheduledAt = task.scheduledAt
        durationMinutes = task.durationMinutes
        instructions = task.instructions
        status = task.status.rawValue
        recurrenceFrequency = task.recurrenceFrequency.rawValue
        recurrenceInterval = task.recurrenceInterval
        recurrenceUnit = task.recurrenceUnit?.rawValue
        createdByID = task.createdByID
    }
}

private struct TaskUpdatePayload: Encodable {
    let title: String
    let scheduledAt: Date
    let durationMinutes: Int
    let instructions: String
    let status: String
    let recurrenceFrequency: String
    let recurrenceInterval: Int
    let recurrenceUnit: String?

    enum CodingKeys: String, CodingKey {
        case title
        case scheduledAt = "scheduled_at"
        case durationMinutes = "duration_minutes"
        case instructions, status
        case recurrenceFrequency = "recurrence_frequency"
        case recurrenceInterval = "recurrence_interval"
        case recurrenceUnit = "recurrence_unit"
    }

    init(from task: CareTask) {
        title = task.title
        scheduledAt = task.scheduledAt
        durationMinutes = task.durationMinutes
        instructions = task.instructions
        status = task.status.rawValue
        recurrenceFrequency = task.recurrenceFrequency.rawValue
        recurrenceInterval = task.recurrenceInterval
        recurrenceUnit = task.recurrenceUnit?.rawValue
    }
}
