import Foundation

struct CareContact: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var careTeamID: UUID
    var name: String
    var relationship: String
    var phone: String
    var email: String
    var avatarSymbolName: String?
    /// Device Contacts identifier when added via the system contact picker.
    var systemContactIdentifier: String?
    /// Supabase auth user id when this contact has joined the app.
    var linkedUserID: UUID?

    init(
        id: UUID = UUID(),
        careTeamID: UUID,
        name: String,
        relationship: String,
        phone: String = "",
        email: String = "",
        avatarSymbolName: String? = nil,
        systemContactIdentifier: String? = nil,
        linkedUserID: UUID? = nil
    ) {
        self.id = id
        self.careTeamID = careTeamID
        self.name = name
        self.relationship = relationship
        self.phone = phone
        self.email = email
        self.avatarSymbolName = avatarSymbolName
        self.systemContactIdentifier = systemContactIdentifier
        self.linkedUserID = linkedUserID
    }

    var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap(\.first)
        if letters.isEmpty, let first = name.first {
            return String(first).uppercased()
        }
        return letters.map { String($0).uppercased() }.joined()
    }
}
