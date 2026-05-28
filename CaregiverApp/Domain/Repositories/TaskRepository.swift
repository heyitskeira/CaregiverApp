import Foundation

protocol TaskRepository: Sendable {
    func fetchAllTasks() async throws -> [CareTask]
    func fetchTasks(assigneeID: UUID) async throws -> [CareTask]
    func saveTask(_ task: CareTask) async throws
    func updateTask(_ task: CareTask) async throws
    func deleteTask(id: UUID) async throws
}
