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
            return .gray.opacity(0.45)
        case .ongoing:
            return Color(red: 0.13, green: 0.55, blue: 0.13)
        case .assigned:
            return Color(red: 0.1, green: 0.2, blue: 0.4)
        case .pending:
            return .clear
        }
    }

    var lineColor: Color {
        switch state {
        case .completed:
            return .gray.opacity(0.35)
        case .ongoing:
            return Color(red: 0.13, green: 0.55, blue: 0.13).opacity(0.5)
        case .assigned:
            return Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.4)
        case .pending:
            return .gray.opacity(0.4)
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

struct TimelineTaskRow: View {
    let task: TimelineTaskModel
    let isLast: Bool
    var rowHeight: CGFloat = 80
    var onToggleComplete: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil

    private var rowOpacity: Double {
        task.isCompleted ? 0.45 : 1.0
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(task.startTimeString)
                .font(.subheadline)
                .foregroundStyle(.gray)
                .frame(width: 45, alignment: .trailing)
                .padding(.top, 10)
                .opacity(rowOpacity)

            VStack(spacing: 0) {
                Group {
                    if let initials = task.initials {
                        if task.isPending {
                            Text(initials)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .frame(width: 50, height: max(50, rowHeight - 10))
                                .background(Color.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
                                        .foregroundColor(.gray.opacity(0.6))
                                )
                        } else {
                            Text(initials)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 50, height: task.isCompleted ? 50 : max(50, rowHeight - 10))
                                .background(task.nodeColor)
                                .clipShape(Capsule())
                        }
                    } else if let icon = task.iconSystemName {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: max(50, rowHeight - 10))
                            .background(task.nodeColor)
                            .clipShape(Capsule())
                    }
                }

                if !isLast {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 2, height: 20)
                        .overlay(
                            Rectangle()
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                                .foregroundColor(task.lineColor)
                        )
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("\(task.startTimeString)-\(task.endTimeString) (\(task.durationString))")
                        .font(.caption)
                        .foregroundStyle(.gray)

                    if task.hasRepeatIcon {
                        Image(systemName: "arrow.2.squarepath")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                }

                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                if task.showDocumentIcon {
                    Image(systemName: "doc.text.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 10)
            .opacity(rowOpacity)
            .contentShape(Rectangle())
            .onTapGesture { onTap?() }

            Spacer()

            if task.isPending {
                HStack(spacing: 12) {
                    Button(action: { onToggleComplete?() }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }

                    Button(action: {}) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, 10)
            } else {
                Button(action: { onToggleComplete?() }) {
                    if task.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.gray.opacity(0.5))
                    } else {
                        Circle()
                            .stroke(task.isOngoing
                                    ? Color(red: 0.13, green: 0.55, blue: 0.13)
                                    : Color(red: 0.1, green: 0.2, blue: 0.4),
                                    lineWidth: 3)
                            .frame(width: 22, height: 22)
                    }
                }
                .padding(.top, 10)
            }
        }
        .frame(minHeight: rowHeight)
    }
}
