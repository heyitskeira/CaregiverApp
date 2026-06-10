import Foundation

@MainActor
struct AppDependencies {
    let contactRepository: any ContactRepository
    let taskRepository: any TaskRepository
    let patientRepository: any PatientRepository
    let logRepository: any LogRepository
    let taskRequestRepository: any TaskRequestRepository

    static let live = AppDependencies(
        contactRepository: MockContactRepository(),
        taskRepository: MockTaskRepository(),
        patientRepository: MockPatientRepository(),
        logRepository: MockLogRepository(),
        taskRequestRepository: MockTaskRequestRepository()
    )
}
