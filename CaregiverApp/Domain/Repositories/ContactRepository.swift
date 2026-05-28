import Foundation

protocol ContactRepository: Sendable {
    func fetchContacts() async throws -> [CareContact]
    func contact(id: UUID) async throws -> CareContact?
    func saveContact(_ contact: CareContact) async throws
    func deleteContact(id: UUID) async throws
}
