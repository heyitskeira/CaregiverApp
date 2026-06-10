import SwiftUI

private struct ContactRepositoryKey: EnvironmentKey {
    @MainActor static let defaultValue: any ContactRepository = MockContactRepository()
}

private struct TaskRepositoryKey: EnvironmentKey {
    @MainActor static let defaultValue: any TaskRepository = MockTaskRepository()
}

private struct PatientRepositoryKey: EnvironmentKey {
    @MainActor static let defaultValue: any PatientRepository = MockPatientRepository()
}

private struct LogRepositoryKey: EnvironmentKey {
    @MainActor static let defaultValue: any LogRepository = MockLogRepository()
}

private struct TaskRequestRepositoryKey: EnvironmentKey {
    @MainActor static let defaultValue: any TaskRequestRepository = MockTaskRequestRepository()
}

extension EnvironmentValues {
    var contactRepository: any ContactRepository {
        get { self[ContactRepositoryKey.self] }
        set { self[ContactRepositoryKey.self] = newValue }
    }

    var taskRepository: any TaskRepository {
        get { self[TaskRepositoryKey.self] }
        set { self[TaskRepositoryKey.self] = newValue }
    }

    var patientRepository: any PatientRepository {
        get { self[PatientRepositoryKey.self] }
        set { self[PatientRepositoryKey.self] = newValue }
    }

    var logRepository: any LogRepository {
        get { self[LogRepositoryKey.self] }
        set { self[LogRepositoryKey.self] = newValue }
    }

    var taskRequestRepository: any TaskRequestRepository {
        get { self[TaskRequestRepositoryKey.self] }
        set { self[TaskRequestRepositoryKey.self] = newValue }
    }
}
