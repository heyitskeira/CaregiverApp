import Foundation
import Supabase

@MainActor
final class SupabasePatientRepository: PatientRepository {
    private let careTeamID: UUID

    init(careTeamID: UUID) {
        self.careTeamID = careTeamID
    }

    func fetchPatient() async throws -> CareRecipient? {
        let rows: [DBPatientRow] = try await supabase
            .from("care_recipients")
            .select()
            .eq("care_team_id", value: careTeamID)
            .limit(1)
            .execute()
            .value
        return rows.first?.toDomain()
    }

    func savePatient(_ patient: CareRecipient) async throws {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withFullDate]
        let payload = PatientPayload(
            id: patient.id,
            careTeamID: careTeamID,
            name: patient.name,
            dateOfBirth: iso.string(from: patient.dateOfBirth),
            gender: patient.gender,
            bloodType: patient.bloodType,
            allergies: patient.allergies,
            favoriteFood: patient.favoriteFood,
            healthNotes: patient.healthNotes
        )
        try await supabase
            .from("care_recipients")
            .upsert(payload)
            .execute()
    }
}

private struct PatientPayload: Encodable {
    let id: UUID
    let careTeamID: UUID
    let name: String
    let dateOfBirth: String
    let gender: String
    let bloodType: String
    let allergies: String
    let favoriteFood: String
    let healthNotes: String

    enum CodingKeys: String, CodingKey {
        case id
        case careTeamID = "care_team_id"
        case name
        case dateOfBirth = "date_of_birth"
        case gender
        case bloodType = "blood_type"
        case allergies
        case favoriteFood = "favorite_food"
        case healthNotes = "health_notes"
    }
}
