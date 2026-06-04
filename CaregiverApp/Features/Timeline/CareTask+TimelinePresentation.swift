import Foundation
import SwiftUI

extension CareTask {
    func timelinePresentation(contactsByID: [UUID: CareContact]) -> TimelineTaskModel {
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .minute, value: durationMinutes, to: scheduledAt) ?? scheduledAt

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH.mm"

        let primaryAssignee = assigneeIDs.first.flatMap { contactsByID[$0] }
        let isCompleted = status == .completed
        let isUnassigned = assigneeIDs.isEmpty

        return TimelineTaskModel(
            id: id,
            startTime: timeFormatter.string(from: scheduledAt),
            endTime: timeFormatter.string(from: endDate),
            duration: Self.durationLabel(minutes: durationMinutes),
            title: title,
            initials: primaryAssignee?.initials,
            isCompleted: isCompleted,
            hasRepeatIcon: recurrence.repeats,
            color: Self.timelineColor(isCompleted: isCompleted, isUnassigned: isUnassigned),
            iconSystemName: isUnassigned ? "person.badge.plus" : nil
        )
    }

    private static func durationLabel(minutes: Int) -> String {
        if minutes >= 60, minutes % 60 == 0 {
            let hours = minutes / 60
            return hours == 1 ? "1 hr" : "\(hours) hr"
        }
        return "\(minutes) min"
    }

    private static func timelineColor(isCompleted: Bool, isUnassigned: Bool) -> Color {
        if isCompleted {
            return .gray.opacity(0.7)
        }
        if isUnassigned {
            return .gray.opacity(0.7)
        }
        return .green.opacity(0.7)
    }
}

extension TaskRecurrence {
    static func from(
        repeatOption: RepeatOption,
        interval: Int,
        unit: RepeatUnit
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
