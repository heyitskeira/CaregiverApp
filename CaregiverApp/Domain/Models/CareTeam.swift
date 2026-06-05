import Foundation

/// A household coordinating care for one patient. All contacts, tasks, and patient data are scoped to a team.
struct CareTeam: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var name: String
    var primaryCaregiverID: UUID
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        primaryCaregiverID: UUID,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.primaryCaregiverID = primaryCaregiverID
        self.createdAt = createdAt
    }
}
