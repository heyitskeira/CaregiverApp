import Foundation
import SwiftUI

extension CareTask {
    func timelinePresentation(contactsByID: [UUID: CareContact]) -> TimelineTaskModel {
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .minute, value: durationMinutes, to: scheduledAt) ?? scheduledAt
        let primaryAssignee = assigneeIDs.first.flatMap { contactsByID[$0] }
        let isUnassigned = assigneeIDs.isEmpty

        return TimelineTaskModel(
            id: id,
            startDate: scheduledAt,
            endDate: endDate,
            title: title,
            initials: primaryAssignee?.initials,
            hasRepeatIcon: recurrence.repeats,
            iconSystemName: isUnassigned ? "person.badge.plus" : nil,
            state: taskState,
            taskNote: instructions,
            repeatOption: recurrence.repeatOption,
            assigneeIDs: assigneeIDs
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

        return CareTask(
            id: timelineModel.id,
            title: timelineModel.title,
            scheduledAt: timelineModel.startDate,
            durationMinutes: durationMinutes,
            instructions: timelineModel.taskNote,
            careTeamID: careTeamID,
            patientID: patientID,
            assigneeIDs: timelineModel.assigneeIDs,
            status: timelineModel.isCompleted ? .completed : (timelineModel.assigneeIDs.isEmpty ? .unassigned : .assigned),
            recurrence: TaskRecurrence.from(repeatOption: timelineModel.repeatOption),
            createdByID: createdByID
        )
    }
}

extension TaskRecurrence {
    static func from(
        repeatOption: RepeatOption,
        interval: Int = 1,
        unit: RepeatUnit = .weeks
    ) -> TaskRecurrence {
        switch repeatOption {
        case .none:
            return .none
        case .daily:
            return TaskRecurrence(frequency: .daily)
        case .weekly:
            return TaskRecurrence(frequency: .weekly)
        case .monthly:
            return TaskRecurrence(frequency: .monthly)
        case .yearly:
            return TaskRecurrence(frequency: .yearly)
        case .custom:
            return TaskRecurrence(
                frequency: .custom,
                interval: interval,
                unit: unit.recurrenceUnit
            )
        }
    }

    var repeatOption: RepeatOption {
        switch frequency {
        case .none:
            return .none
        case .daily:
            return .daily
        case .weekly:
            return .weekly
        case .monthly:
            return .monthly
        case .yearly:
            return .yearly
        case .custom:
            return .custom
        }
    }
}

private extension RepeatUnit {
    var recurrenceUnit: TaskRecurrenceUnit {
        switch self {
        case .days: .days
        case .weeks: .weeks
        case .months: .months
        case .years: .years
        }
    }
}
