import Foundation

protocol PatientRepository: Sendable {
    func fetchPatient() async throws -> CareRecipient?
    func savePatient(_ patient: CareRecipient) async throws
}
