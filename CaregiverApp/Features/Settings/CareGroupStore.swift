import Foundation
import Observation

@Observable
@MainActor
final class CareGroupStore {
    private(set) var contacts: [CareContact] = []
    private(set) var isLoading = false
    var errorMessage: String?

    private let contactRepository: any ContactRepository

    init(contactRepository: any ContactRepository) {
        self.contactRepository = contactRepository
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            contacts = try await contactRepository.fetchContacts()
        } catch {
            errorMessage = "Could not load care group contacts."
        }
    }

    func save(_ contact: CareContact) async throws {
        try await contactRepository.saveContact(contact)
        await load()
    }

    func delete(id: UUID) async {
        do {
            try await contactRepository.deleteContact(id: id)
            await load()
        } catch {
            errorMessage = "Could not remove contact."
        }
    }
}
