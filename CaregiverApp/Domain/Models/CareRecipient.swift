import Foundation

struct CareRecipient: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var name: String
    var dateOfBirth: Date
    var gender: String
    var bloodType: String
    var allergies: String
    var favoriteFood: String
    var healthNotes: String

    init(
        id: UUID = UUID(),
        name: String,
        dateOfBirth: Date,
        gender: String,
        bloodType: String,
        allergies: String = "",
        favoriteFood: String = "",
        healthNotes: String = ""
    ) {
        self.id = id
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.gender = gender
        self.bloodType = bloodType
        self.allergies = allergies
        self.favoriteFood = favoriteFood
        self.healthNotes = healthNotes
    }
}
