import Foundation

// Codable DB row types used by Supabase repositories.
// Prefixed with "DB" to avoid name collisions with Supabase SDK internal types.

struct DBContactRow: Codable {
    let id: UUID
    let careTeamID: UUID
    var name: String
    var relationship: String
    var phone: String
    var email: String
    var avatarSymbolName: String?
    var systemContactIdentifier: String?
    var linkedUserID: UUID?

    enum CodingKeys: String, CodingKey {
        case id
        case careTeamID = "care_team_id"
        case name, relationship, phone, email
        case avatarSymbolName = "avatar_symbol_name"
        case systemContactIdentifier = "system_contact_identifier"
        case linkedUserID = "linked_user_id"
    }

    func toDomain() -> CareContact {
        CareContact(
            id: id, careTeamID: careTeamID, name: name,
            relationship: relationship, phone: phone, email: email,
            avatarSymbolName: avatarSymbolName,
            systemContactIdentifier: systemContactIdentifier,
            linkedUserID: linkedUserID
        )
    }
}

struct DBPatientRow: Codable {
    let id: UUID
    let careTeamID: UUID
    var name: String
    /// PostgreSQL `date` columns return "YYYY-MM-DD" — decode as String to avoid
    /// the Swift ISO8601 decoder rejecting a date-only string.
    var dateOfBirth: String
    var gender: String
    var bloodType: String
    var allergies: String
    var favoriteFood: String
    var healthNotes: String
    var createdAt: Date?
    var updatedAt: Date?

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
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    func toDomain() -> CareRecipient {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let dob = formatter.date(from: dateOfBirth) ?? Date()
        return CareRecipient(
            id: id, careTeamID: careTeamID, name: name,
            dateOfBirth: dob, gender: gender, bloodType: bloodType,
            allergies: allergies, favoriteFood: favoriteFood,
            healthNotes: healthNotes,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
}

struct DBTaskRow: Codable {
    let id: UUID
    let careTeamID: UUID
    let patientID: UUID
    var title: String
    var scheduledAt: Date
    var durationMinutes: Int
    var instructions: String
    var status: TaskStatus
    var recurrenceFrequency: TaskRecurrenceFrequency
    var recurrenceInterval: Int
    var recurrenceUnit: TaskRecurrenceUnit?
    var createdByID: UUID
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case careTeamID = "care_team_id"
        case patientID = "patient_id"
        case title
        case scheduledAt = "scheduled_at"
        case durationMinutes = "duration_minutes"
        case instructions, status
        case recurrenceFrequency = "recurrence_frequency"
        case recurrenceInterval = "recurrence_interval"
        case recurrenceUnit = "recurrence_unit"
        case createdByID = "created_by_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    func toDomain() -> CareTask {
        CareTask(
            id: id, title: title, scheduledAt: scheduledAt,
            durationMinutes: durationMinutes, instructions: instructions,
            careTeamID: careTeamID, patientID: patientID,
            status: status,
            recurrenceFrequency: recurrenceFrequency,
            recurrenceInterval: recurrenceInterval,
            recurrenceUnit: recurrenceUnit,
            createdByID: createdByID,
            createdAt: createdAt, updatedAt: updatedAt
        )
    }
}

struct DBAssignmentRow: Codable {
    let id: UUID
    let taskID: UUID
    let assigneeID: UUID
    let assignedByID: UUID
    let assignedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case taskID = "task_id"
        case assigneeID = "assignee_id"
        case assignedByID = "assigned_by_id"
        case assignedAt = "assigned_at"
    }

    func toDomain() -> TaskAssignment {
        TaskAssignment(id: id, taskID: taskID, assigneeID: assigneeID,
                       assignedByID: assignedByID, assignedAt: assignedAt)
    }
}

struct DBRequestRow: Codable {
    let id: UUID
    let taskID: UUID
    let requesterID: UUID
    var status: TaskRequestStatus
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case taskID = "task_id"
        case requesterID = "requester_id"
        case status
        case createdAt = "created_at"
    }

    func toDomain() -> TaskRequest {
        TaskRequest(id: id, taskID: taskID, requesterID: requesterID,
                    status: status, createdAt: createdAt)
    }
}
