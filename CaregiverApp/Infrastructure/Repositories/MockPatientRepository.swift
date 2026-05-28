import Foundation

@MainActor
final class MockPatientRepository: PatientRepository {
    private var patient: CareRecipient?

    init(patient: CareRecipient? = SeedData.patient) {
        self.patient = patient
    }

    func fetchPatient() async throws -> CareRecipient? {
        patient
    }

    func savePatient(_ patient: CareRecipient) async throws {
        self.patient = patient
    }
}
