import Foundation

/// Signed-in app user. Maps to the `profiles` table in Supabase.
/// Role is determined by `care_team_members`, not stored here.
struct UserProfile: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var name: String
    var phone: String
    var email: String
    var avatarURL: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        phone: String = "",
        email: String = "",
        avatarURL: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        self.avatarURL = avatarURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
