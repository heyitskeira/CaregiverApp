import Foundation

@MainActor
struct AppDependencies {
    let contactRepository: any ContactRepository
    let taskRepository: any TaskRepository
    let patientRepository: any PatientRepository

    static let live = AppDependencies(
        contactRepository: MockContactRepository(),
        taskRepository: MockTaskRepository(),
        patientRepository: MockPatientRepository()
    )
}
