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
    /// The care_recipients.id for this care team. Set at login/sign-up; used
    /// as the patient_id FK when creating tasks.
    var currentPatientID: UUID? { get }
    /// The care_contacts.id for the signed-in user. Set at login/sign-up; used
    /// as the author_contact_id FK when creating logs.
    var currentContactID: UUID? { get }

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
