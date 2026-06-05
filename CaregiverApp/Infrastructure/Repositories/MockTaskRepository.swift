import Foundation

@MainActor
final class MockTaskRepository: TaskRepository {
    private var tasks: [CareTask]

    init(tasks: [CareTask] = SeedData.sampleTasks) {
        self.tasks = tasks
    }

    func fetchAllTasks() async throws -> [CareTask] {
        tasks.sorted { $0.scheduledAt < $1.scheduledAt }
    }

    func fetchTasks(assigneeID: UUID) async throws -> [CareTask] {
        tasks
            .filter { $0.isAssigned(to: assigneeID) }
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
    }
}
