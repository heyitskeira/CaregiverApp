import Foundation

/// The role a user holds within a care team.
/// Maps to the Supabase `caregiver_role` enum type.
enum CaregiverRole: String, Codable, Sendable, CaseIterable {
    case primaryCaregiver = "primary_caregiver"
    case helper
}

/// Maps to the `care_team_members` table in Supabase.
/// Determines a user's role within a specific care team.
struct CareTeamMember: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var careTeamID: UUID
    var userID: UUID
    var role: CaregiverRole
    var createdAt: Date

    init(
        id: UUID = UUID(),
        careTeamID: UUID,
        userID: UUID,
        role: CaregiverRole,
        createdAt: Date = .now
    ) {
        self.id = id
        self.careTeamID = careTeamID
        self.userID = userID
        self.role = role
        self.createdAt = createdAt
    }
}
