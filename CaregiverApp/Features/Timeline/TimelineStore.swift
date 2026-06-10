import Foundation

@MainActor
@Observable
final class TimelineStore {
    private let taskRepository: any TaskRepository
    private let contactRepository: any ContactRepository
    private let patientRepository: any PatientRepository
    private let currentUserID: UUID

    private(set) var tasks: [TimelineTaskModel] = []
    private(set) var isLoading = false
    /// Populated from the real patient row on first `load()`. Falls back to SeedData for mock/preview.
    private(set) var currentPatientID: UUID = SeedData.patientID

    init(
        taskRepository: any TaskRepository,
        contactRepository: any ContactRepository,
        patientRepository: any PatientRepository,
        currentUserID: UUID = SeedData.primaryCaregiverID
    ) {
        self.taskRepository = taskRepository
        self.contactRepository = contactRepository
        self.patientRepository = patientRepository
        self.currentUserID = currentUserID
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Resolve the real patient ID once per load so task saves use the correct FK.
            do {
                if let patient = try await patientRepository.fetchPatient() {
                    currentPatientID = patient.id
                } else {
                    print("[TimelineStore] fetchPatient() returned nil — no patient row for this care team")
                }
            } catch {
                print("[TimelineStore] fetchPatient() error: \(error)")
            }

            let contacts = try await contactRepository.fetchContacts()
            var contactsByID: [UUID: CareContact] = [:]
            for contact in contacts {
                contactsByID[contact.id] = contact
            }
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
        // Tasks with no assignees remain in the `.unassigned` state — do NOT force-assign
        // to a hardcoded seed UUID which would fail the Supabase care_contacts FK constraint.
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

    // MARK: - Helpers

    /// UUID of the current signed-in user — used as `created_by_id` when building CareTasks.
    var resolvedUserID: UUID { currentUserID }

    func deleteTask(id: UUID) async throws {
        try await taskRepository.deleteTask(id: id)
        await load()
    }
}
