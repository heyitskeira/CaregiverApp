import Foundation
import Supabase

@MainActor
final class SupabaseContactRepository: ContactRepository {
    private let careTeamID: UUID

    init(careTeamID: UUID) {
        self.careTeamID = careTeamID
    }

    func fetchContacts() async throws -> [CareContact] {
        let rows: [DBContactRow] = try await supabase
            .from("care_contacts")
            .select()
            .eq("care_team_id", value: careTeamID)
            .order("name")
            .execute()
            .value
        return rows.map { $0.toDomain() }
    }

    func contact(id: UUID) async throws -> CareContact? {
        let rows: [DBContactRow] = try await supabase
            .from("care_contacts")
            .select()
            .eq("id", value: id)
            .limit(1)
            .execute()
            .value
        return rows.first?.toDomain()
    }

    func saveContact(_ contact: CareContact) async throws {
        let payload = ContactPayload(
            id: contact.id,
            careTeamID: careTeamID,
            name: contact.name,
            relationship: contact.relationship,
            phone: contact.phone,
            email: contact.email,
            avatarSymbolName: contact.avatarSymbolName,
            systemContactIdentifier: contact.systemContactIdentifier,
            linkedUserID: contact.linkedUserID
        )
        try await supabase
            .from("care_contacts")
            .upsert(payload)
            .execute()
    }

    func deleteContact(id: UUID) async throws {
        try await supabase
            .from("care_contacts")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}

private struct ContactPayload: Encodable {
    let id: UUID
    let careTeamID: UUID
    let name: String
    let relationship: String
    let phone: String
    let email: String
    let avatarSymbolName: String?
    let systemContactIdentifier: String?
    let linkedUserID: UUID?

    enum CodingKeys: String, CodingKey {
        case id
        case careTeamID = "care_team_id"
        case name, relationship, phone, email
        case avatarSymbolName = "avatar_symbol_name"
        case systemContactIdentifier = "system_contact_identifier"
        case linkedUserID = "linked_user_id"
    }
}
