import Foundation

struct CareContact: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var name: String
    var relationship: String
    var phone: String
    var email: String
    var avatarSymbolName: String?
    /// Device Contacts identifier when added via the system contact picker.
    var systemContactIdentifier: String?

    init(
        id: UUID = UUID(),
        name: String,
        relationship: String,
        phone: String = "",
        email: String = "",
        avatarSymbolName: String? = nil,
        systemContactIdentifier: String? = nil
    ) {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.phone = phone
        self.email = email
        self.avatarSymbolName = avatarSymbolName
        self.systemContactIdentifier = systemContactIdentifier
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
