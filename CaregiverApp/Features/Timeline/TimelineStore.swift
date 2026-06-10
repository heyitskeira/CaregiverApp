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
            var contactsByID: [UUID: CareContact] = [:]
            for contact in contacts {
                contactsByID[contact.id] = contact
            }
            let careTasks = try await taskRepository.fetchAllTasks()
            tasks = careTasks.map { $0.timelinePresentation(contactsByID: contactsByID) }
        } catch {
            tasks = []
        }
    }

    func save(_ careTask: CareTask) async throws {
        try await taskRepository.saveTask(careTask)
        await load()
    }

    func update(_ careTask: CareTask) async throws {
        try await taskRepository.updateTask(careTask)
        await load()
    }
}
