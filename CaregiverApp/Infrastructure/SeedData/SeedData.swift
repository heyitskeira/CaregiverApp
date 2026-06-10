import Foundation

enum SeedData {
    static let careTeamID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let patientID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let lilyID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    static let jamesID = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
    static let annaID = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
    static let primaryCaregiverID = UUID(uuidString: "00000000-0000-0000-0000-000000000006")!
    static let myTasksViewerContactID = lilyID
    static let hospitalVisitTaskID = UUID(uuidString: "00000000-0000-0000-0000-000000000007")!

    static let careTeam = CareTeam(
        id: careTeamID,
        name: "Marie’s Care Team",
        primaryCaregiverID: primaryCaregiverID
    )

    static let primaryCaregiver = UserProfile(
        id: primaryCaregiverID,
        name: "Sarah Sechan",
        phone: "+628123456789",
        email: "sarah@example.com",
        role: .primaryCaregiver
    )

    static let patient = CareRecipient(
        id: patientID,
        careTeamID: careTeamID,
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
            careTeamID: careTeamID,
            name: "Lily",
            relationship: "Daughter",
            phone: "+62 123-456-789",
            email: "lily@example.com"
        ),
        CareContact(
            id: jamesID,
            careTeamID: careTeamID,
            name: "James",
            relationship: "Son",
            phone: "+62 123-456-790",
            email: "james@example.com"
        ),
        CareContact(
            id: annaID,
            careTeamID: careTeamID,
            name: "Anna",
            relationship: "Friend",
            phone: "+62 123-456-791",
            email: "anna@example.com"
        ),
    ]

    static func makeSampleTasks(on referenceDate: Date = .now) -> [CareTask] {
        let calendar = Calendar.current
        return [
            CareTask(
                title: "Give Meds",
                scheduledAt: calendar.date(bySettingHour: 6, minute: 0, second: 0, of: referenceDate)!,
                durationMinutes: 15,
                instructions: "Morning medication with breakfast.",
                careTeamID: careTeamID,
                patientID: patientID,
                assigneeIDs: [lilyID],
                status: .assigned,
                recurrence: TaskRecurrence(frequency: .daily),
                createdByID: primaryCaregiverID
            ),
            CareTask(
                id: hospitalVisitTaskID,
                title: "Hospital Visit",
                scheduledAt: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: referenceDate)!,
                durationMinutes: 120,
                instructions: "Bring insurance card and appointment letter.",
                careTeamID: careTeamID,
                patientID: patientID,
                createdByID: primaryCaregiverID
            ),
        ]
    }

    /// Sample tasks scheduled on today — refreshed each time the mock repository is created.
    static var sampleTasks: [CareTask] { makeSampleTasks() }

    static let sampleTaskRequests: [TaskRequest] = [
        TaskRequest(taskID: hospitalVisitTaskID, requesterID: annaID),
        TaskRequest(taskID: hospitalVisitTaskID, requesterID: jamesID),
    ]

    static let sampleAssignments: [TaskAssignment] = TaskAssignment.records(
        for: sampleTasks[0],
        assignedByID: primaryCaregiverID
    )
}
