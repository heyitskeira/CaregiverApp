import Foundation

@MainActor
@Observable
final class TimelineStore {
    private let taskRepository: any TaskRepository
    private let contactRepository: any ContactRepository

    private(set) var tasks: [TimelineTaskModel] = []
    private(set) var isLoading = false

    init(taskRepository: any TaskRepository, contactRepository: any ContactRepository) {
        self.taskRepository = taskRepository
        self.contactRepository = contactRepository
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let contacts = try await contactRepository.fetchContacts()
            let contactsByID = Dictionary(uniqueKeysWithValues: contacts.map { ($0.id, $0) })
            let careTasks = try await taskRepository.fetchAllTasks()

            var models: [TimelineTaskModel] = []
            for task in careTasks {
                let assignments = try await taskRepository.fetchAssignments(taskID: task.id)
                let model = task.timelinePresentation(
                    assignments: assignments,
                    contactsByID: contactsByID
                )
                models.append(model)
            }
            tasks = models
        } catch {
            tasks = []
        }
    }

    func save(_ careTask: CareTask, assignments: [TaskAssignment] = []) async throws {
        try await taskRepository.saveTask(careTask)
        for assignment in assignments {
            try await taskRepository.addAssignment(assignment)
        }
        if assignments.isEmpty {
            let autoAssignment = TaskAssignment(
                taskID: careTask.id,
                assigneeID: SeedData.primaryCaregiverID,
                assignedByID: SeedData.primaryCaregiverID
            )
            try await taskRepository.addAssignment(autoAssignment)
        }
        await load()
    }

    func update(_ careTask: CareTask, assignments: [TaskAssignment]? = nil) async throws {
        try await taskRepository.updateTask(careTask)
        if let assignments {
            let old = try await taskRepository.fetchAssignments(taskID: careTask.id)
            for a in old {
                try await taskRepository.removeAssignment(taskID: a.taskID, assigneeID: a.assigneeID)
            }
            for a in assignments {
                try await taskRepository.addAssignment(a)
            }
        }
        await load()
    }

    func deleteTask(id: UUID) async throws {
        try await taskRepository.deleteTask(id: id)
        await load()
    }
}
