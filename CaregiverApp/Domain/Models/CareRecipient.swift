import Foundation

struct CareRecipient: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var careTeamID: UUID
    var name: String
    var dateOfBirth: Date
    var gender: String
    var bloodType: String
    var allergies: String
    var favoriteFood: String
    var healthNotes: String
    var createdAt: Date
    var updatedAt: Date

    var ageInYears: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year ?? 0
    }

    var dateOfBirthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: dateOfBirth)
    }

    init(
        id: UUID = UUID(),
        careTeamID: UUID,
        name: String,
        dateOfBirth: Date,
        gender: String,
        bloodType: String,
        allergies: String = "",
        favoriteFood: String = "",
        healthNotes: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.careTeamID = careTeamID
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.bloodType = bloodType
        self.allergies = allergies
        self.favoriteFood = favoriteFood
        self.healthNotes = healthNotes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
