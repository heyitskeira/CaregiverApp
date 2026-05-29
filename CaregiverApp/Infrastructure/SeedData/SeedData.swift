import Foundation

enum SeedData {
    static let patientID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let lilyID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let jamesID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    static let annaID = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
    static let primaryCaregiverID = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!

    static let patient = CareRecipient(
        id: patientID,
        name: "Grandma Marie",
        dateOfBirth: Calendar.current.date(from: DateComponents(year: 1946, month: 4, day: 21))!,
        gender: "Female",
        bloodType: "O+",
        allergies: "Penicillin",
        favoriteFood: "Pizza",
        healthNotes: "Has had cancer for about a year; regular check-ups every two months."
    )

    static let contacts: [CareContact] = [
        CareContact(
            id: lilyID,
            name: "Lily",
            relationship: "Daughter",
            phone: "+62 123-456-789",
            email: "lily@example.com"
        ),
        CareContact(
            id: jamesID,
            name: "James",
            relationship: "Son",
            phone: "+62 123-456-790",
            email: "james@example.com"
        ),
        CareContact(
            id: annaID,
            name: "Anna",
            relationship: "Friend",
            phone: "+62 123-456-791",
            email: "anna@example.com"
        ),
    ]

    static let sampleTasks: [CareTask] = [
        CareTask(
            title: "Give Meds",
            scheduledAt: Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: .now)!,
            durationMinutes: 15,
            instructions: "Morning medication with breakfast.",
            patientID: patientID,
            assigneeID: lilyID,
            status: .assigned
        ),
        CareTask(
            title: "Hospital Visit",
            scheduledAt: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: .now)!,
            durationMinutes: 120,
            instructions: "Bring insurance card and appointment letter.",
            patientID: patientID,
            status: .unassigned
        ),
    ]
}
