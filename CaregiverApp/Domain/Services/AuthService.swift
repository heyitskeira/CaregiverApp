import Foundation
import SwiftUI

/// Manages the current user session and role-based permissions.
/// Prepared for Supabase Auth integration.
///
/// ## Supabase Integration Guide
/// When connecting to Supabase:
/// 1. Replace `MockAuthService` with `SupabaseAuthService` in `AppDependencies`
/// 2. Use `supabase.auth.session` to get the current user
/// 3. Fetch the user profile from a `profiles` table keyed by `auth.uid()`
/// 4. The `CaregiverRole` is stored in the `profiles.role` column
/// 5. Use Supabase RLS policies to enforce permissions server-side
@MainActor
protocol AuthService: Observable {
    var currentUser: UserProfile? { get }
    var isAuthenticated: Bool { get }
    var currentRole: CaregiverRole { get }

    func signIn(email: String, password: String) async throws
    func signOut() async throws
    func refreshSession() async throws
}

/// Role-based permission checks
extension CaregiverRole {
    /// Primary caregivers can create, edit, and delete tasks
    var canCreateTask: Bool {
        self == .primaryCaregiver
    }

    var canEditTask: Bool {
        self == .primaryCaregiver
    }

    var canDeleteTask: Bool {
        self == .primaryCaregiver
    }

    /// All roles can view tasks and receive assignments
    var canViewTasks: Bool { true }

    /// All roles can view their inbox
    var canViewInbox: Bool { true }

    /// Display name for the role
    var displayName: String {
        switch self {
        case .primaryCaregiver: return "Primary Caregiver"
        case .helper: return "Helper"
        }
    }
}
