import Foundation

protocol TaskRepository: Sendable {
    // MARK: - Tasks
    func fetchAllTasks() async throws -> [CareTask]
    func fetchTasks(assigneeID: UUID) async throws -> [CareTask]
    func saveTask(_ task: CareTask) async throws
    func updateTask(_ task: CareTask) async throws
    func deleteTask(id: UUID) async throws

    // MARK: - Assignments
    func fetchAssignments(taskID: UUID) async throws -> [TaskAssignment]
    func fetchAssignments(assigneeID: UUID) async throws -> [TaskAssignment]
    func addAssignment(_ assignment: TaskAssignment) async throws
    func removeAssignment(taskID: UUID, assigneeID: UUID) async throws

    // MARK: - Requests
    func fetchPendingRequests(forUser userID: UUID) async throws -> [TaskRequest]
    func fetchAllPendingRequests() async throws -> [TaskRequest]
    func createRequest(_ request: TaskRequest) async throws
    func updateRequestStatus(id: UUID, status: TaskRequestStatus) async throws
}
