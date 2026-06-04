import Foundation

@MainActor
@Observable
final class TimelineStore {
    private let taskRepository: any TaskRepository
    private let contactRepository: any ContactRepository

    private(set) var allTasks: [TimelineTaskModel] = []
    private(set) var myTasks: [TimelineTaskModel] = []
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

            let tasks = try await taskRepository.fetchAllTasks()
            allTasks = tasks.map { $0.timelinePresentation(contactsByID: contactsByID) }

            let memberTasks = try await taskRepository.fetchTasks(
                assigneeID: SeedData.myTasksViewerContactID
            )
            myTasks = memberTasks.map { $0.timelinePresentation(contactsByID: contactsByID) }
        } catch {
            allTasks = []
            myTasks = []
        }
    }
}
