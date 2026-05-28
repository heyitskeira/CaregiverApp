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
}
