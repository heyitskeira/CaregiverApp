import Foundation
import SwiftUI

extension CareTask {
    func timelinePresentation(
        assignments: [TaskAssignment],
        contactsByID: [UUID: CareContact]
    ) -> TimelineTaskModel {
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .minute, value: durationMinutes, to: scheduledAt) ?? scheduledAt

        let assigneeIDs = assignments.map { $0.assigneeID }
        let primaryAssignee = assigneeIDs.first.flatMap { contactsByID[$0] }
        let backupAssignee = assigneeIDs.count > 1 ? assigneeIDs[1] : nil
        let isUnassigned = assigneeIDs.isEmpty

        return TimelineTaskModel(
            id: id,
            startDate: scheduledAt,
            endDate: endDate,
            title: title,
            initials: primaryAssignee?.initials,
            hasRepeatIcon: hasRecurrence,
            iconSystemName: isUnassigned ? "person.badge.plus" : nil,
            state: taskState,
            taskNote: instructions,
            repeatOption: recurrenceFrequency.toRepeatOption,
            primaryAssigneeID: assigneeIDs.first,
            backupAssigneeID: backupAssignee,
            attachments: attachments
        )
    }

    private var taskState: TaskState {
        switch status {
        case .completed:
            return .completed
        case .unassigned:
            return .pending
        case .assigned:
            return .assigned
        }
    }

    static func from(
        timelineModel: TimelineTaskModel,
        careTeamID: UUID = SeedData.careTeamID,
        patientID: UUID = SeedData.patientID,
        createdByID: UUID = SeedData.primaryCaregiverID
    ) -> CareTask {
        let durationMinutes = max(
            1,
            Int(timelineModel.endDate.timeIntervalSince(timelineModel.startDate) / 60)
        )

        let hasAssignees = timelineModel.primaryAssigneeID != nil

        return CareTask(
            id: timelineModel.id,
            title: timelineModel.title,
            scheduledAt: timelineModel.startDate,
            durationMinutes: durationMinutes,
            instructions: timelineModel.taskNote,
            careTeamID: careTeamID,
            patientID: patientID,
            status: timelineModel.isCompleted ? .completed : (hasAssignees ? .assigned : .unassigned),
            recurrenceFrequency: timelineModel.repeatOption.toRecurrenceFrequency,
            createdByID: createdByID,
            attachments: timelineModel.attachments
        )
    }

    static func assignments(
        from timelineModel: TimelineTaskModel,
        assignedByID: UUID = SeedData.primaryCaregiverID
    ) -> [TaskAssignment] {
        var results: [TaskAssignment] = []
        if let primary = timelineModel.primaryAssigneeID {
            results.append(TaskAssignment(
                taskID: timelineModel.id,
                assigneeID: primary,
                assignedByID: assignedByID
            ))
        }
        if let backup = timelineModel.backupAssigneeID {
            results.append(TaskAssignment(
                taskID: timelineModel.id,
                assigneeID: backup,
                assignedByID: assignedByID
            ))
        }
        return results
    }
}

// MARK: - RepeatOption ↔ TaskRecurrenceFrequency conversion

enum RepeatOption: String, CaseIterable {
    case none = "Does not repeat"
    case daily = "Every day"
    case weekly = "Every week"
    case monthly = "Every month"
    case yearly = "Every year"
    case custom = "Custom"

    var toRecurrenceFrequency: TaskRecurrenceFrequency {
        switch self {
        case .none: .none
        case .daily: .daily
        case .weekly: .weekly
        case .monthly: .monthly
        case .yearly: .yearly
        case .custom: .custom
        }
    }
}

enum RepeatUnit: String, CaseIterable {
    case days = "Days"
    case weeks = "Weeks"
    case months = "Months"
    case years = "Years"

    var toRecurrenceUnit: TaskRecurrenceUnit {
        switch self {
        case .days: .days
        case .weeks: .weeks
        case .months: .months
        case .years: .years
        }
    }
}

extension TaskRecurrenceFrequency {
    var toRepeatOption: RepeatOption {
        switch self {
        case .none: .none
        case .daily: .daily
        case .weekly: .weekly
        case .monthly: .monthly
        case .yearly: .yearly
        case .custom: .custom
        }
    }
}
