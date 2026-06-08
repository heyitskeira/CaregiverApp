import SwiftUI
import Combine

enum TimelineFilter: String, CaseIterable {
    case all = "All Task"
    case mine = "My Task"
}

struct TimelineView: View {
    @Binding var tasks: [TimelineTaskModel]
    @Binding var selectedDate: Date
    var myTasksAssigneeID: UUID = SeedData.myTasksViewerContactID
    var onTaskTapped: ((TimelineTaskModel) -> Void)? = nil
    var onTaskStatusChanged: ((TimelineTaskModel) -> Void)? = nil

    @State private var currentTime = Date()
    @State private var activeFilter: TimelineFilter = .all
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    private let pointsPerMinute: CGFloat = 1.2
    private let minTaskHeight: CGFloat = 80
    private let gapBetweenTasks: CGFloat = 16

    private var calendar: Calendar { Calendar.current }

    var filteredTasks: [TimelineTaskModel] {
        let dayStart = calendar.startOfDay(for: selectedDate)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!

        let dayTasks = tasks.filter { task in
            task.startDate >= dayStart && task.startDate < dayEnd
        }

        let filtered: [TimelineTaskModel]
        switch activeFilter {
        case .all:
            filtered = dayTasks
        case .mine:
            filtered = dayTasks.filter { $0.assigneeIDs.contains(myTasksAssigneeID) }
        }

        return filtered.sorted { $0.startDate < $1.startDate }
    }

    private func taskHeight(for task: TimelineTaskModel) -> CGFloat {
        max(minTaskHeight, CGFloat(task.durationMinutes) * pointsPerMinute)
    }

    private func currentTimeOffset() -> CGFloat? {
        let now = currentTime
        guard !filteredTasks.isEmpty else { return nil }

        let dayStart = calendar.startOfDay(for: selectedDate)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
        guard now >= dayStart && now < dayEnd else { return nil }

        var offset: CGFloat = 0

        for (index, task) in filteredTasks.enumerated() {
            let height = taskHeight(for: task)

            if now < task.startDate {
                return offset + 10
            }

            if now >= task.startDate && now <= task.endDate {
                let elapsed = now.timeIntervalSince(task.startDate)
                let total = task.endDate.timeIntervalSince(task.startDate)
                let fraction = CGFloat(elapsed / total)
                return offset + height * fraction
            }

            offset += height

            if index < filteredTasks.count - 1 {
                offset += gapBetweenTasks
            }
        }

        return offset + 10
    }

    private func weekDates(around date: Date) -> [Date] {
        let weekday = calendar.component(.weekday, from: date)
        let sundayOffset = -(weekday - 1)
        guard let sunday = calendar.date(byAdding: .day, value: sundayOffset, to: date) else {
            return []
        }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: sunday) }
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            weekCalendarSection
            filterPillToggle
                .padding(.top, 16)
            Divider()
                .padding(.top, 12)
            timelineScrollSection
        }
        .background(Color(.systemBackground))
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            HStack(spacing: 4) {
                // "26 May" in blue
                Text(headerDateString)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: 0x2051B9))

                // "2026 >" in black
                Text(selectedDate.formatted(.dateTime.year()))
                    .font(.title2)
                    .fontWeight(.bold)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }

            Spacer()

            NavigationLink(destination: InboxView()) {
                Image(systemName: "tray.fill")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Circle())
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(.red)
                            .frame(width: 10, height: 10)
                            .offset(x: 2, y: -2)
                    }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var headerDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: selectedDate)
    }

    // MARK: - Week Calendar
    private var weekCalendarSection: some View {
        HStack(spacing: 0) {
            let week = weekDates(around: selectedDate)
            let dayFormatter: DateFormatter = {
                let f = DateFormatter()
                f.dateFormat = "EEE"
                return f
            }()

            ForEach(week, id: \.self) { day in
                let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedDate = day
                    }
                } label: {
                    VStack(spacing: 6) {
                        Text(dayFormatter.string(from: day).uppercased())
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.gray)

                        Text("\(calendar.component(.day, from: day))")
                            .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                            .foregroundStyle(isSelected ? .primary : .primary)
                            .frame(width: 36, height: 36)
                            .background {
                                if isSelected {
                                    Circle().fill(Color(.systemGray5))
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 16)
    }

    // MARK: - Filter Pill Toggle
    private var filterPillToggle: some View {
        HStack(spacing: 0) {
            ForEach(TimelineFilter.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        activeFilter = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background {
                            if activeFilter == tab {
                                Capsule().fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
        .padding(.horizontal)
    }

    // MARK: - Timeline Scroll
    private var timelineScrollSection: some View {
        Group {
            if filteredTasks.isEmpty {
                VStack {
                    Spacer()
                    Text("No Task Added")
                        .font(.body)
                        .foregroundStyle(.gray)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    ZStack(alignment: .topLeading) {
                        VStack(spacing: gapBetweenTasks) {
                            ForEach(filteredTasks.indices, id: \.self) { index in
                                let task = filteredTasks[index]
                                let height = taskHeight(for: task)
                                TimelineTaskRow(
                                    task: task,
                                    isLast: index == filteredTasks.count - 1,
                                    rowHeight: height,
                                    onToggleComplete: {
                                        toggleTask(task)
                                    },
                                    onAccept: {
                                        acceptTask(task)
                                    },
                                    onDecline: {
                                        declineTask(task)
                                    },
                                    onTap: {
                                        onTaskTapped?(task)
                                    }
                                )
                                .padding(.bottom, index == filteredTasks.count - 1 ? 120 : 0)
                            }
                        }
                        .padding(.horizontal)

                        if let offset = currentTimeOffset() {
                            CurrentTimeIndicator(currentTime: currentTime)
                                .offset(y: offset)
                        }
                    }
                }
            }
        }
    }

    private func toggleTask(_ task: TimelineTaskModel) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        if tasks[index].state == .completed {
            tasks[index].state = tasks[index].previousState ?? .assigned
            tasks[index].previousState = nil
        } else {
            tasks[index].previousState = tasks[index].state
            tasks[index].state = .completed
        }
        onTaskStatusChanged?(tasks[index])
    }

    private func acceptTask(_ task: TimelineTaskModel) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].state = .assigned
        onTaskStatusChanged?(tasks[index])
    }

    private func declineTask(_ task: TimelineTaskModel) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks.remove(at: index)
    }
}

struct CurrentTimeIndicator: View {
    var currentTime: Date

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: currentTime)
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(timeString)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.red)
                .clipShape(Capsule())
                .padding(.leading, 8)

            Rectangle()
                .fill(Color.red)
                .frame(height: 1.5)
                .padding(.trailing, 24)
        }
    }
}

// MARK: - Color hex extension
extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}

#Preview {
    @Previewable @State var selectedDate = Date()
    @Previewable @State var tasks: [TimelineTaskModel] = []
    NavigationStack {
        TimelineView(tasks: $tasks, selectedDate: $selectedDate)
    }
}
