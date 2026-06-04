//
//  ContentView.swift
//  CaregiverApp
//

import SwiftUI

enum AppTab: String, CaseIterable {
    case allTask
    case myTask
    case settings
    case addTask

    var title: String {
        switch self {
        case .allTask:
            return "All Task"
        case .myTask:
            return "My Task"
        case .settings:
            return "Settings"
        case .addTask:
            return "Add Task"
        }
    }

    var icon: String {
        switch self {
        case .allTask:
            return "list.bullet.rectangle.portrait"
        case .myTask:
            return "person.crop.circle.badge.checkmark"
        case .settings:
            return "gearshape"
        case .addTask:
            return "plus"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .allTask
    @State private var showTaskSheet = false
    @State private var selectedDate: Date = Date()

    @State private var taskSheetMode: TaskSheetMode = .create
    @State private var showDetailSheet = false

    @State private var tasks: [TimelineTaskModel] = {
        let today = Date()
        return [
            TimelineTaskModel(
                startDate: TimelineTaskModel.makeDate(hour: 5, minute: 0, from: today),
                endDate: TimelineTaskModel.makeDate(hour: 5, minute: 30, from: today),
                title: "Prep Breakfast",
                initials: "AA",
                hasRepeatIcon: true,
                state: .completed
            ),
            TimelineTaskModel(
                startDate: TimelineTaskModel.makeDate(hour: 6, minute: 0, from: today),
                endDate: TimelineTaskModel.makeDate(hour: 6, minute: 15, from: today),
                title: "Change Diaper",
                initials: "J",
                hasRepeatIcon: true,
                state: .completed
            ),
            TimelineTaskModel(
                startDate: TimelineTaskModel.makeDate(hour: 6, minute: 15, from: today),
                endDate: TimelineTaskModel.makeDate(hour: 6, minute: 30, from: today),
                title: "Give Meds",
                initials: "B",
                hasRepeatIcon: true,
                state: .completed
            ),
            TimelineTaskModel(
                startDate: TimelineTaskModel.makeDate(hour: 6, minute: 30, from: today),
                endDate: TimelineTaskModel.makeDate(hour: 7, minute: 30, from: today),
                title: "Give Bfast",
                initials: "SA",
                hasRepeatIcon: true,
                state: .completed
            ),
            TimelineTaskModel(
                startDate: TimelineTaskModel.makeDate(hour: 9, minute: 0, from: today),
                endDate: TimelineTaskModel.makeDate(hour: 10, minute: 0, from: today),
                title: "Give Bath",
                initials: "SA",
                hasRepeatIcon: true,
                state: .ongoing
            ),
            TimelineTaskModel(
                startDate: TimelineTaskModel.makeDate(hour: 13, minute: 0, from: today),
                endDate: TimelineTaskModel.makeDate(hour: 15, minute: 0, from: today),
                title: "Hospital Visit",
                initials: "AA",
                state: .pending
            ),
            TimelineTaskModel(
                startDate: TimelineTaskModel.makeDate(hour: 17, minute: 0, from: today),
                endDate: TimelineTaskModel.makeDate(hour: 17, minute: 30, from: today),
                title: "Prepare Dinner",
                initials: "AA",
                hasRepeatIcon: true,
                state: .assigned,
                showDocumentIcon: true
            ),
            TimelineTaskModel(
                startDate: TimelineTaskModel.makeDate(hour: 19, minute: 0, from: today),
                endDate: TimelineTaskModel.makeDate(hour: 19, minute: 30, from: today),
                title: "Give Meds",
                initials: "AA",
                hasRepeatIcon: true,
                state: .assigned,
                showDocumentIcon: true
            )
        ]
    }()

    var body: some View {

        TabView(selection: $selectedTab) {
            Tab(
                AppTab.allTask.title,
                systemImage: AppTab.allTask.icon,
                value: AppTab.allTask
            ) {
                NavigationStack {
                    TimelineView(
                        filter: .all,
                        tasks: $tasks,
                        selectedDate: $selectedDate,
                        onTaskTapped: { task in
                            taskSheetMode = .view(task)
                            showDetailSheet = true
                        }
                    )
                }
            }

            Tab(
                AppTab.myTask.title,
                systemImage: AppTab.myTask.icon,
                value: .myTask
            ) {
                NavigationStack {
                    TimelineView(
                        filter: .mine,
                        tasks: $tasks,
                        selectedDate: $selectedDate,
                        onTaskTapped: { task in
                            taskSheetMode = .view(task)
                            showDetailSheet = true
                        }
                    )
                }
            }

            Tab(
                AppTab.settings.title,
                systemImage: AppTab.settings.icon,
                value: .settings
            ) {
                SettingsRootView()
            }

            Tab(
                AppTab.addTask.title,
                systemImage: AppTab.addTask.icon,
                value: .addTask,
                role: .search
            ) {}
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .addTask {
                selectedTab = oldValue
                taskSheetMode = .create
                showTaskSheet = true
            }
        }
        .sheet(isPresented: $showTaskSheet) {
            TaskSheetView(
                mode: .create,
                onSave: { newTask in
                    tasks.append(newTask)
                }
            )
        }
        .sheet(isPresented: $showDetailSheet) {
            TaskSheetView(
                mode: taskSheetMode,
                onUpdate: { updatedTask in
                    if let idx = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
                        tasks[idx] = updatedTask
                    }
                }
            )
        }
    }
}

#Preview {
    ContentView()
        .environment(\.contactRepository, AppDependencies.live.contactRepository)
        .environment(\.taskRepository, AppDependencies.live.taskRepository)
        .environment(\.patientRepository, AppDependencies.live.patientRepository)
}
