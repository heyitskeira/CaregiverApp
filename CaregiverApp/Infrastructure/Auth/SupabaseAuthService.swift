import Foundation
import Observation
import Supabase

@Observable
@MainActor
final class SupabaseAuthService: AuthService {
    private(set) var currentUser: UserProfile?
    private(set) var currentMembership: CareTeamMember?

    var isAuthenticated: Bool { currentUser != nil }
    var currentUserID: UUID? { currentUser?.id }
    var currentRole: CaregiverRole { currentMembership?.role ?? .helper }

    init() {
        Task { await restoreSession() }
    }

    func signIn(email: String, password: String) async throws {
        let session = try await supabase.auth.signIn(email: email, password: password)
        try await loadProfile(userID: session.user.id)
    }

    func signUp(name: String, email: String, password: String) async throws {
        let session = try await supabase.auth.signUp(
            email: email,
            password: password,
            data: ["full_name": .string(name)]
        )
        try await loadProfile(userID: session.user.id)
    }

    func signOut() async throws {
        try await supabase.auth.signOut()
        currentUser = nil
        currentMembership = nil
    }

    func refreshSession() async throws {
        let session = try await supabase.auth.refreshSession()
        try await loadProfile(userID: session.user.id)
    }

    // MARK: - Private

    private func restoreSession() async {
        do {
            let session = try await supabase.auth.session
            try await loadProfile(userID: session.user.id)
        } catch {
            currentUser = nil
            currentMembership = nil
        }
    }

    private func loadProfile(userID: UUID) async throws {
        struct ProfileRow: Codable {
            let id: UUID
            let name: String
            let phone: String
            let email: String
            let avatarURL: String?
            let createdAt: Date
            let updatedAt: Date

            enum CodingKeys: String, CodingKey {
                case id, name, phone, email
                case avatarURL = "avatar_url"
                case createdAt = "created_at"
                case updatedAt = "updated_at"
            }
        }

        struct MemberRow: Codable {
            let id: UUID
            let careTeamID: UUID
            let userID: UUID
            let role: CaregiverRole
            let createdAt: Date

            enum CodingKeys: String, CodingKey {
                case id
                case careTeamID = "care_team_id"
                case userID = "user_id"
                case role
                case createdAt = "created_at"
            }
        }

        let profile: ProfileRow = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userID)
            .single()
            .execute()
            .value

        currentUser = UserProfile(
            id: profile.id,
            name: profile.name,
            phone: profile.phone,
            email: profile.email,
            avatarURL: profile.avatarURL,
            createdAt: profile.createdAt,
            updatedAt: profile.updatedAt
        )

        let memberships: [MemberRow] = try await supabase
            .from("care_team_members")
            .select()
            .eq("user_id", value: userID)
            .limit(1)
            .execute()
            .value
        let membership = memberships.first

        if let m = membership {
            currentMembership = CareTeamMember(
                id: m.id,
                careTeamID: m.careTeamID,
                userID: m.userID,
                role: m.role,
                createdAt: m.createdAt
            )
        }
    }

    // MARK: - Onboarding helpers

    /// Creates care team + patient + adds creator as primary caregiver member.
    func createCareTeam(name: String, patientName: String, patientDOB: Date) async throws -> (CareTeam, CareRecipient) {
        guard let userID = currentUserID else { throw AuthError.notAuthenticated }

        struct TeamRow: Codable {
            let id: UUID
            let name: String
            let primaryCaregiverID: UUID
            let createdAt: Date
            enum CodingKeys: String, CodingKey {
                case id, name
                case primaryCaregiverID = "primary_caregiver_id"
                case createdAt = "created_at"
            }
        }

        struct RecipientRow: Codable {
            let id: UUID
            enum CodingKeys: String, CodingKey { case id }
        }

        let team: TeamRow = try await supabase
            .from("care_teams")
            .insert(["name": name, "primary_caregiver_id": userID.uuidString])
            .select()
            .single()
            .execute()
            .value

        try await supabase.from("care_team_members").insert([
            "care_team_id": team.id.uuidString,
            "user_id": userID.uuidString,
            "role": CaregiverRole.primaryCaregiver.rawValue
        ]).execute()

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withFullDate]
        let recipient: RecipientRow = try await supabase
            .from("care_recipients")
            .insert([
                "care_team_id": team.id.uuidString,
                "name": patientName,
                "date_of_birth": iso.string(from: patientDOB),
                "gender": "", "blood_type": "", "allergies": "", "favorite_food": "", "health_notes": ""
            ])
            .select("id")
            .single()
            .execute()
            .value

        currentMembership = CareTeamMember(
            careTeamID: team.id,
            userID: userID,
            role: .primaryCaregiver
        )

        let careTeam = CareTeam(id: team.id, name: team.name, primaryCaregiverID: team.primaryCaregiverID, createdAt: team.createdAt)
        let patient = CareRecipient(id: recipient.id, careTeamID: team.id, name: patientName, dateOfBirth: patientDOB, gender: "", bloodType: "")
        return (careTeam, patient)
    }

    /// Joins an existing care team using an invite code (care_team_id as the code for now).
    func joinCareTeam(code: String) async throws -> CareTeam {
        guard let userID = currentUserID else { throw AuthError.notAuthenticated }
        guard let teamID = UUID(uuidString: code) else { throw AuthError.invalidInviteCode }

        struct TeamRow: Codable {
            let id: UUID
            let name: String
            let primaryCaregiverID: UUID
            let createdAt: Date
            enum CodingKeys: String, CodingKey {
                case id, name
                case primaryCaregiverID = "primary_caregiver_id"
                case createdAt = "created_at"
            }
        }

        let team: TeamRow = try await supabase
            .from("care_teams")
            .select()
            .eq("id", value: teamID)
            .single()
            .execute()
            .value

        try await supabase.from("care_team_members").upsert([
            "care_team_id": teamID.uuidString,
            "user_id": userID.uuidString,
            "role": CaregiverRole.helper.rawValue
        ]).execute()

        currentMembership = CareTeamMember(
            careTeamID: teamID,
            userID: userID,
            role: .helper
        )

        return CareTeam(id: team.id, name: team.name, primaryCaregiverID: team.primaryCaregiverID, createdAt: team.createdAt)
    }
}

enum AuthError: LocalizedError {
    case notAuthenticated
    case invalidInviteCode

    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "You must be signed in."
        case .invalidInviteCode: return "Invalid invite code."
        }
    }
}
