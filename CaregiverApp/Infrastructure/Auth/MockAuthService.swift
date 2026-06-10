import Foundation
import SwiftUI

/// Mock auth service for local development.
/// Role is sourced from CareTeamMember records, not UserProfile.
@Observable
@MainActor
final class MockAuthService: AuthService {
    var currentUser: UserProfile?
    var currentMembership: CareTeamMember?

    var isAuthenticated: Bool { currentUser != nil }

    var currentUserID: UUID? { currentUser?.id }

    var currentPatientID: UUID? { SeedData.patientID }

    var currentContactID: UUID? { SeedData.primaryCaregiverID }

    var currentRole: CaregiverRole {
        currentMembership?.role ?? .helper
    }

    init() {
        // Default: signed in as primary caregiver
        self.currentUser = SeedData.primaryCaregiver
        self.currentMembership = SeedData.primaryCaregiverMember
    }

    func signIn(email: String, password: String) async throws {
        try await Task.sleep(for: .milliseconds(500))
        currentUser = SeedData.primaryCaregiver
        currentMembership = SeedData.primaryCaregiverMember
    }

    func signOut() async throws {
        currentUser = nil
        currentMembership = nil
    }

    func refreshSession() async throws {
        // No-op for mock
    }

    /// Helper for testing: switch to a helper (secondary caregiver) role
    func switchToHelperRole() {
        currentUser = UserProfile(
            id: SeedData.lilyID,
            name: "Lily",
            phone: "+62 123-456-789",
            email: "lily@example.com"
        )
        currentMembership = CareTeamMember(
            careTeamID: SeedData.careTeamID,
            userID: SeedData.lilyID,
            role: .helper
        )
    }
}
