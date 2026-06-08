import Foundation
import SwiftUI

/// Mock auth service for local development.
/// Simulates a signed-in primary caregiver by default.
///
/// Replace with `SupabaseAuthService` when integrating Supabase.
@Observable
@MainActor
final class MockAuthService: AuthService {
    var currentUser: UserProfile?
    var isAuthenticated: Bool { currentUser != nil }

    var currentRole: CaregiverRole {
        currentUser?.role ?? .helper
    }

    init() {
        // Default: signed in as primary caregiver
        self.currentUser = SeedData.primaryCaregiver
    }

    func signIn(email: String, password: String) async throws {
        // Simulate sign-in delay
        try await Task.sleep(for: .milliseconds(500))
        currentUser = SeedData.primaryCaregiver
    }

    func signOut() async throws {
        currentUser = nil
    }

    func refreshSession() async throws {
        // No-op for mock
    }

    /// Helper for testing: switch to a secondary caregiver role
    func switchToHelperRole() {
        currentUser = UserProfile(
            id: SeedData.lilyID,
            name: "Lily",
            phone: "+62 123-456-789",
            email: "lily@example.com",
            role: .helper
        )
    }
}
