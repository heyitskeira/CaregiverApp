import Foundation

enum SeedData {
    // MARK: - Fixed IDs
    static let careTeamID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let patientID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let lilyID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    static let jamesID = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
    static let annaID = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
    static let primaryCaregiverID = UUID(uuidString: "00000000-0000-0000-0000-000000000006")!
    static let giveMedsTaskID = UUID(uuidString: "00000000-0000-0000-0000-000000000010")!
    static let hospitalVisitTaskID = UUID(uuidString: "00000000-0000-0000-0000-000000000007")!
    static let eveningCheckTaskID = UUID(uuidString: "00000000-0000-0000-0000-000000000011")!

    /// The contact ID to use for "My Tasks" filtering (simulates logged-in user's contact)
    static let myTasksViewerContactID = lilyID

    // MARK: - Profiles (no role — role is on CareTeamMember)

    static let primaryCaregiver = UserProfile(
        id: primaryCaregiverID,
        name: "Sarah Sechan",
        phone: "+628123456789",
        email: "sarah@example.com"
    )

    // MARK: - Care Team

    static let careTeam = CareTeam(
        id: careTeamID,
        name: "Marie's Care Team",
        primaryCaregiverID: primaryCaregiverID
    )

    // MARK: - Care Team Members (source of role truth)

    static let primaryCaregiverMember = CareTeamMember(
        careTeamID: careTeamID,
        userID: primaryCaregiverID,
        role: .primaryCaregiver
    )

    static let careTeamMembers: [CareTeamMember] = [
        primaryCaregiverMember,
        CareTeamMember(careTeamID: careTeamID, userID: lilyID, role: .helper),
        CareTeamMember(careTeamID: careTeamID, userID: jamesID, role: .helper),
        CareTeamMember(careTeamID: careTeamID, userID: annaID, role: .helper),
    ]

    // MARK: - Patient

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

    // MARK: - Contacts

    static let contacts: [CareContact] = [
        CareContact(
            id: lilyID,
            careTeamID: careTeamID,
            name: "Lily",
            relationship: "Daughter",
            phone: "+62 123-456-789",
            email: "lily@example.com",
            linkedUserID: lilyID
        ),
        CareContact(
            id: jamesID,
            careTeamID: careTeamID,
            name: "James",
            relationship: "Son",
            phone: "+62 123-456-790",
            email: "james@example.com",
            linkedUserID: jamesID
        ),
        CareContact(
            id: annaID,
            careTeamID: careTeamID,
            name: "Anna",
            relationship: "Friend",
            phone: "+62 123-456-791",
            email: "anna@example.com",
            linkedUserID: annaID
        ),
    ]

    // MARK: - Tasks (no assigneeIDs — assignments are separate)

    static let sampleTasks: [CareTask] = [
        CareTask(
            id: giveMedsTaskID,
            title: "Give Meds",
            scheduledAt: Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: .now)!,
            durationMinutes: 15,
            instructions: "Morning medication with breakfast.",
            careTeamID: careTeamID,
            patientID: patientID,
            status: .assigned,
            recurrenceFrequency: .daily,
            createdByID: primaryCaregiverID
        ),
        CareTask(
            id: hospitalVisitTaskID,
            title: "Hospital Visit",
            scheduledAt: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: .now)!,
            durationMinutes: 120,
            instructions: "Bring insurance card and appointment letter.",
            careTeamID: careTeamID,
            patientID: patientID,
            status: .unassigned,
            createdByID: primaryCaregiverID
        ),
        CareTask(
            id: eveningCheckTaskID,
            title: "Evening Check-in",
            scheduledAt: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: .now)!,
            durationMinutes: 30,
            instructions: "Check vitals and prepare dinner.",
            careTeamID: careTeamID,
            patientID: patientID,
            status: .assigned,
            createdByID: primaryCaregiverID
        ),
    ]

    // MARK: - Assignments (separate table)

    static let sampleAssignments: [TaskAssignment] = [
        // "Give Meds" is assigned to Lily
        TaskAssignment(
            taskID: giveMedsTaskID,
            assigneeID: lilyID,
            assignedByID: primaryCaregiverID
        ),
        // "Hospital Visit" — unassigned, auto-assigned to primary
        TaskAssignment(
            taskID: hospitalVisitTaskID,
            assigneeID: primaryCaregiverID,
            assignedByID: primaryCaregiverID
        ),
        // "Evening Check-in" assigned to James
        TaskAssignment(
            taskID: eveningCheckTaskID,
            assigneeID: jamesID,
            assignedByID: primaryCaregiverID
        ),
    ]

    // MARK: - Task Requests (pending inbox items)

    static let sampleTaskRequests: [TaskRequest] = [
        TaskRequest(taskID: hospitalVisitTaskID, requesterID: annaID),
        TaskRequest(taskID: hospitalVisitTaskID, requesterID: jamesID),
    ]
}
