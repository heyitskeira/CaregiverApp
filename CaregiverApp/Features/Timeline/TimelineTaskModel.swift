//
//  TimelineTaskModel.swift
//  CaregiverApp
//
//  Data model for timeline tasks and their states.
//

import SwiftUI

enum TaskState {
    case completed
    case ongoing
    case assigned
    case pending
}

struct TimelineTaskModel: Identifiable {
    let id: UUID
    var startDate: Date
    var endDate: Date
    var title: String
    var initials: String?
    var hasRepeatIcon: Bool
    var iconSystemName: String?
    var state: TaskState = .assigned
    var previousState: TaskState? = nil
    var showDocumentIcon: Bool = false
    var taskNote: String = ""
    var repeatOption: RepeatOption = .none

    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date,
        title: String,
        initials: String? = nil,
        hasRepeatIcon: Bool = false,
        iconSystemName: String? = nil,
        state: TaskState = .assigned,
        showDocumentIcon: Bool = false,
        taskNote: String = "",
        repeatOption: RepeatOption = .none
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.title = title
        self.initials = initials
        self.hasRepeatIcon = hasRepeatIcon
        self.iconSystemName = iconSystemName
        self.state = state
        self.showDocumentIcon = showDocumentIcon
        self.taskNote = taskNote
        self.repeatOption = repeatOption
    }

    var isCompleted: Bool { state == .completed }
    var isPending: Bool { state == .pending }
    var isOngoing: Bool { state == .ongoing }
    var isAssigned: Bool { state == .assigned }

    var durationMinutes: Double {
        endDate.timeIntervalSince(startDate) / 60.0
    }

    var startTimeString: String {
        let f = DateFormatter()
        f.dateFormat = "HH.mm"
        return f.string(from: startDate)
    }

    var endTimeString: String {
        let f = DateFormatter()
        f.dateFormat = "HH.mm"
        return f.string(from: endDate)
    }

    var durationString: String {
        let mins = Int(durationMinutes)
        if mins >= 60 {
            let hrs = mins / 60
            let rem = mins % 60
            if rem == 0 {
                return "\(hrs) hr"
            }
            return "\(hrs) hr \(rem) min"
        }
        return "\(mins) min"
    }

    var nodeColor: Color {
        switch state {
        case .completed:
            return AppTheme.completedNode
        case .ongoing:
            return AppTheme.ongoingNode
        case .assigned:
            return AppTheme.assignedNode
        case .pending:
            return .clear
        }
    }

    var lineColor: Color {
        switch state {
        case .completed:
            return AppTheme.completedNode.opacity(0.5)
        case .ongoing:
            return AppTheme.ongoingNode.opacity(0.5)
        case .assigned:
            return AppTheme.assignedNode.opacity(0.4)
        case .pending:
            return AppTheme.secondaryText.opacity(0.4)
        }
    }

    static func makeDate(hour: Int, minute: Int, from reference: Date = Date()) -> Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: reference)
        comps.hour = hour
        comps.minute = minute
        comps.second = 0
        return cal.date(from: comps) ?? reference
    }
}
