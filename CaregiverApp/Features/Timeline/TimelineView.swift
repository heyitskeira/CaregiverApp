//
//  TimelineView.swift
//  CaregiverApp
//
//  Main timeline view showing tasks for the selected day.
//

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

    var body: some View {
        VStack(spacing: 0) {
            TimelineHeaderSection(selectedDate: selectedDate)
            WeekCalendarSection(selectedDate: $selectedDate)
            Divider()
                .overlay(AppTheme.divider)
                .padding(.vertical, 16)
            timelineScrollSection
        }
        .background(AppTheme.pageBackground)
        .onReceive(timer) { _ in
            currentTime = Date()
        }
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

    private func acceptTask(_ task: TimelineTaskModel) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx].state = .assigned
    }

    private func declineTask(_ task: TimelineTaskModel) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks.remove(at: idx)
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
