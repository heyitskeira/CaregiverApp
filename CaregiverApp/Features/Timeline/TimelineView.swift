import SwiftUI
import Combine

enum TimelineFilter {
    case all
    case mine
}

struct TimelineView: View {
    var filter: TimelineFilter = .all
    @Binding var tasks: [TimelineTaskModel]
    @Binding var selectedDate: Date
    var onTaskTapped: ((TimelineTaskModel) -> Void)? = nil

    @State private var currentTime = Date()
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
        switch filter {
        case .all:
            filtered = dayTasks
        case .mine:
            filtered = dayTasks.filter { $0.initials == "AA" }
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

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            weekCalendarSection
            Divider().padding(.vertical, 16)
            timelineScrollSection
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }

    private var headerSection: some View {
        HStack {
            HStack(spacing: 8) {
                Text(selectedDate.formatted(.dateTime.day().month(.wide)))
                    .font(.title2)
                    .fontWeight(.bold)
                Text(selectedDate.formatted(.dateTime.year()))
                    .font(.title2)
                    .foregroundStyle(.gray)
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            Spacer()

            NavigationLink(destination: InboxView()) {
                Image(systemName: "tray.fill")
                    .font(.title2)
                    .foregroundColor(.black)
                    .padding(12)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Circle())
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(.red)
                            .frame(width: 12, height: 12)
                            .offset(x: 0, y: 0)
                    }
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }

    private var weekCalendarSection: some View {
        HStack {
            let week = weekDates(around: selectedDate)
            let dayFormatter: DateFormatter = {
                let f = DateFormatter()
                f.dateFormat = "EEE"
                return f
            }()

            ForEach(week, id: \.self) { day in
                let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
                let isToday = calendar.isDateInToday(day)

                Button(action: {
                    selectedDate = day
                }) {
                    VStack(spacing: 8) {
                        Text(dayFormatter.string(from: day).uppercased())
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray.opacity(0.8))

                        Text("\(calendar.component(.day, from: day))")
                            .font(.headline)
                            .fontWeight(isSelected ? .bold : .semibold)
                            .foregroundStyle(isSelected ? Color.accentColor : (isToday ? Color.accentColor.opacity(0.7) : .primary))
                            .frame(width: 36, height: 36)
                            .background {
                                if isSelected {
                                    Circle().fill(Color.accentColor.opacity(0.15))
                                }
                            }
                    }
                }
                .buttonStyle(.plain)
                if day != week.last { Spacer() }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    private var timelineScrollSection: some View {
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

    private func toggleTask(_ task: TimelineTaskModel) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        if tasks[idx].state == .completed {
            tasks[idx].state = tasks[idx].previousState ?? .assigned
            tasks[idx].previousState = nil
        } else {
            tasks[idx].previousState = tasks[idx].state
            tasks[idx].state = .completed
        }
    }
}

struct CurrentTimeIndicator: View {
    var currentTime: Date

    private var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: currentTime)
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

#Preview {
    @Previewable @State var selectedDate = Date()
    @Previewable @State var tasks: [TimelineTaskModel] = [
        TimelineTaskModel(
            startDate: TimelineTaskModel.makeDate(hour: 5, minute: 0),
            endDate: TimelineTaskModel.makeDate(hour: 5, minute: 30),
            title: "Prepare Bfast",
            initials: "AA",
            hasRepeatIcon: true,
            state: .completed
        ),
        TimelineTaskModel(
            startDate: TimelineTaskModel.makeDate(hour: 9, minute: 0),
            endDate: TimelineTaskModel.makeDate(hour: 10, minute: 0),
            title: "Give Bath",
            initials: "SA",
            hasRepeatIcon: true,
            state: .ongoing
        ),
        TimelineTaskModel(
            startDate: TimelineTaskModel.makeDate(hour: 13, minute: 0),
            endDate: TimelineTaskModel.makeDate(hour: 15, minute: 0),
            title: "Hospital Visit",
            initials: "AA",
            state: .pending
        )
    ]
    NavigationStack {
        TimelineView(filter: .all, tasks: $tasks, selectedDate: $selectedDate)
    }
}
