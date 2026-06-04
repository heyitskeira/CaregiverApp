import Foundation

enum CaregiverRole: String, Codable, Sendable, CaseIterable {
    case primaryCaregiver = "primary_caregiver"
    case helper
}

/// Signed-in app user. Maps to `auth.users` in Supabase via matching UUID.
struct UserProfile: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var name: String
    var phone: String
    var email: String
    var role: CaregiverRole
    var avatarURL: String?

    init(
        id: UUID = UUID(),
        name: String,
        phone: String = "",
        email: String = "",
        role: CaregiverRole = .helper,
        avatarURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        self.role = role
        self.avatarURL = avatarURL
    }
}
