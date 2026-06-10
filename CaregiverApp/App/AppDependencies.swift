import Foundation

@MainActor
struct AppDependencies {
    let contactRepository: any ContactRepository
    let taskRepository: any TaskRepository
    let patientRepository: any PatientRepository
    let authService: any AuthService
    let logRepository: any LogRepository

    static let live = AppDependencies(
        contactRepository: MockContactRepository(),
        taskRepository: MockTaskRepository(),
        patientRepository: MockPatientRepository(),
        authService: MockAuthService(),
        logRepository: MockLogRepository()
    )
}
