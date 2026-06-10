import Foundation

@MainActor
final class MockTaskRepository: TaskRepository {
    private var tasks: [CareTask]
    private var assignments: [TaskAssignment]
    private var requests: [TaskRequest]

    init(
        tasks: [CareTask] = SeedData.sampleTasks,
        assignments: [TaskAssignment] = SeedData.sampleAssignments,
        requests: [TaskRequest] = SeedData.sampleTaskRequests
    ) {
        self.tasks = tasks
        self.assignments = assignments
        self.requests = requests
    }

    // MARK: - Tasks

    func fetchAllTasks() async throws -> [CareTask] {
        tasks.sorted { $0.scheduledAt < $1.scheduledAt }
    }

    func fetchTasks(assigneeID: UUID) async throws -> [CareTask] {
        let assignedTaskIDs = Set(
            assignments
                .filter { $0.assigneeID == assigneeID }
                .map { $0.taskID }
        )
        return tasks
            .filter { assignedTaskIDs.contains($0.id) }
            .sorted { $0.scheduledAt < $1.scheduledAt }
    }

    func saveTask(_ task: CareTask) async throws {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        } else {
            tasks.append(task)
        }
    }

    func updateTask(_ task: CareTask) async throws {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
    }

    func deleteTask(id: UUID) async throws {
        tasks.removeAll { $0.id == id }
        assignments.removeAll { $0.taskID == id }
        requests.removeAll { $0.taskID == id }
    }

    // MARK: - Assignments

    func fetchAssignments(taskID: UUID) async throws -> [TaskAssignment] {
        assignments.filter { $0.taskID == taskID }
    }

    func fetchAssignments(assigneeID: UUID) async throws -> [TaskAssignment] {
        assignments.filter { $0.assigneeID == assigneeID }
    }

    func addAssignment(_ assignment: TaskAssignment) async throws {
        // Prevent duplicate
        guard !assignments.contains(where: {
            $0.taskID == assignment.taskID && $0.assigneeID == assignment.assigneeID
        }) else { return }
        assignments.append(assignment)
    }

    func removeAssignment(taskID: UUID, assigneeID: UUID) async throws {
        assignments.removeAll { $0.taskID == taskID && $0.assigneeID == assigneeID }
    }

    // MARK: - Requests

    func fetchPendingRequests(forUser userID: UUID) async throws -> [TaskRequest] {
        requests.filter { $0.requesterID == userID && $0.status == .pending }
    }

    func fetchAllPendingRequests() async throws -> [TaskRequest] {
        requests.filter { $0.status == .pending }
    }

    func createRequest(_ request: TaskRequest) async throws {
        requests.append(request)
    }

    func updateRequestStatus(id: UUID, status: TaskRequestStatus) async throws {
        guard let index = requests.firstIndex(where: { $0.id == id }) else { return }
        requests[index].status = status
    }
}
