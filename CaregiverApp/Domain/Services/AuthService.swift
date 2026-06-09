import Foundation
import SwiftUI

/// Manages the current user session and role-based permissions.
/// Prepared for Supabase Auth integration.
@MainActor
protocol AuthService: Observable {
    var currentUser: UserProfile? { get }
    var isAuthenticated: Bool { get }
    var currentRole: CaregiverRole { get }
    var currentUserID: UUID? { get }

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

    /// All roles can view tasks
    var canViewTasks: Bool { true }

    /// All roles can accept task requests
    var canAcceptRequest: Bool { true }

    /// All roles can complete tasks assigned to them
    var canCompleteTask: Bool { true }

    /// All roles can post logs
    var canPostLog: Bool { true }

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
