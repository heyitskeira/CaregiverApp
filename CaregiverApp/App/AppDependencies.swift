import Foundation

@MainActor
struct AppDependencies {
    let contactRepository: any ContactRepository
    let taskRepository: any TaskRepository
    let patientRepository: any PatientRepository
    let authService: any AuthService
    let logRepository: any LogRepository

    /// Mock stack — used in SwiftUI Previews and before sign-in.
    static let live = AppDependencies(
        contactRepository: MockContactRepository(),
        taskRepository: MockTaskRepository(),
        patientRepository: MockPatientRepository(),
        authService: MockAuthService(),
        logRepository: MockLogRepository()
    )

    /// Real Supabase stack — built once auth resolves a careTeamID.
    static func supabase(authService: SupabaseAuthService) -> AppDependencies {
        let careTeamID = authService.currentMembership?.careTeamID ?? UUID()
        let userID = authService.currentUserID ?? UUID()
        return AppDependencies(
            contactRepository: SupabaseContactRepository(careTeamID: careTeamID),
            taskRepository: SupabaseTaskRepository(careTeamID: careTeamID, currentUserID: userID),
            patientRepository: SupabasePatientRepository(careTeamID: careTeamID),
            authService: authService,
            logRepository: SupabaseLogRepository(careTeamID: careTeamID)
        )
    }
}
