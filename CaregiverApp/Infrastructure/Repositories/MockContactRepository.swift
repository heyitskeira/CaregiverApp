import Foundation

@MainActor
final class MockContactRepository: ContactRepository {
    private var contacts: [CareContact]

    init(contacts: [CareContact] = SeedData.contacts) {
        self.contacts = contacts
    }

    func fetchContacts() async throws -> [CareContact] {
        contacts.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    func contact(id: UUID) async throws -> CareContact? {
        contacts.first { $0.id == id }
    }

    func saveContact(_ contact: CareContact) async throws {
        if let systemID = contact.systemContactIdentifier,
           let index = contacts.firstIndex(where: { $0.systemContactIdentifier == systemID }) {
            var updated = contact
            updated = CareContact(
                id: contacts[index].id,
                name: contact.name,
                relationship: contact.relationship,
                phone: contact.phone,
                email: contact.email,
                avatarSymbolName: contact.avatarSymbolName,
                systemContactIdentifier: contact.systemContactIdentifier
            )
            contacts[index] = updated
            return
        }

        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index] = contact
        } else {
            contacts.append(contact)
        }
    }

    func deleteContact(id: UUID) async throws {
        contacts.removeAll { $0.id == id }
    }
}
