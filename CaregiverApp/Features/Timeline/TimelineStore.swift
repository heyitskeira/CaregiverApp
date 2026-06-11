import Foundation

@MainActor
@Observable
final class TimelineStore {
    private let taskRepository: any TaskRepository
    private let contactRepository: any ContactRepository

    private(set) var tasks: [TimelineTaskModel] = []
    private(set) var isLoading = false
    
    // Temporary local cache for attachments until Supabase schema supports them
    private var attachmentsCache: [UUID: [TaskAttachment]] = [:]

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
            let allPendingRequests = try await taskRepository.fetchAllPendingRequests()
            let requestedTaskIDs = Set(allPendingRequests.map { $0.taskID })

            var models: [TimelineTaskModel] = []
            for task in careTasks {
                let assignments = try await taskRepository.fetchAssignments(taskID: task.id)
                var model = task.timelinePresentation(
                    assignments: assignments,
                    contactsByID: contactsByID
                )
                if let cached = attachmentsCache[task.id] {
                    model.attachments = cached
                    model.showDocumentIcon = !cached.isEmpty
                }
                if task.status == .unassigned && requestedTaskIDs.contains(task.id) {
                    model.isRequested = true
                }
                models.append(model)
            }
            tasks = models
        } catch {
            tasks = []
        }
    }

    func save(_ careTask: CareTask, assignments: [TaskAssignment] = []) async throws {
        attachmentsCache[careTask.id] = careTask.attachments
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
        
        // Expand recurrence if needed (only on creation)
        if careTask.recurrenceFrequency != .none {
            try await expandRecurrence(for: careTask, assignments: assignments.isEmpty ? [
                TaskAssignment(taskID: careTask.id, assigneeID: SeedData.primaryCaregiverID, assignedByID: SeedData.primaryCaregiverID)
            ] : assignments)
        }

        await load()
    }

    private func expandRecurrence(for baseTask: CareTask, assignments: [TaskAssignment]) async throws {
        let calendar = Calendar.current
        var limit = 0
        var component: Calendar.Component = .day

        switch baseTask.recurrenceFrequency {
        case .daily:
            limit = 30 // Create next 30 days
            component = .day
        case .weekly:
            limit = 12 // Next 12 weeks
            component = .weekOfYear
        case .monthly:
            limit = 12 // Next 12 months
            component = .month
        case .yearly:
            limit = 5 // Next 5 years
            component = .year
        default: return
        }

        for i in 1...limit {
            guard let nextDate = calendar.date(byAdding: component, value: i, to: baseTask.scheduledAt) else { continue }
            
            var nextTask = baseTask
            nextTask.id = UUID()
            nextTask.scheduledAt = nextDate
            // Note: we don't clear recurrenceFrequency so the UI still shows the repeat icon
            
            attachmentsCache[nextTask.id] = baseTask.attachments
            try await taskRepository.saveTask(nextTask)
            
            for a in assignments {
                let nextAssignment = TaskAssignment(
                    id: UUID(),
                    taskID: nextTask.id,
                    assigneeID: a.assigneeID,
                    assignedByID: a.assignedByID
                )
                try await taskRepository.addAssignment(nextAssignment)
            }
        }
    }

    func update(_ careTask: CareTask, assignments: [TaskAssignment]? = nil) async throws {
        attachmentsCache[careTask.id] = careTask.attachments
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
