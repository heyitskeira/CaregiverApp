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
        case .allTask: "All Task"
        case .myTask: "My Task"
        case .settings: "Settings"
        case .addTask: "Add Task"
        }
    }

    var icon: String {
        switch self {
        case .allTask: "list.bullet.rectangle.portrait"
        case .myTask: "person.crop.circle.badge.checkmark"
        case .settings: "gearshape"
        case .addTask: "plus"
        }
    }
}

struct ContentView: View {
    @Environment(\.taskRepository) private var taskRepository
    @Environment(\.contactRepository) private var contactRepository

    @State private var selectedTab: AppTab = .allTask
    @State private var showTaskSheet = false
    @State private var selectedDate = Date()
    @State private var taskSheetMode: TaskSheetMode = .create
    @State private var showDetailSheet = false
    @State private var tasks: [TimelineTaskModel] = []
    @State private var store: TimelineStore?
    @State private var reloadToken = UUID()

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTab.allTask.title, systemImage: AppTab.allTask.icon, value: AppTab.allTask) {
                NavigationStack {
                    TimelineView(
                        filter: .all,
                        tasks: $tasks,
                        selectedDate: $selectedDate,
                        onTaskTapped: openTaskDetail,
                        onTaskStatusChanged: persistTaskStatus
                    )
                }
            }

            Tab(AppTab.myTask.title, systemImage: AppTab.myTask.icon, value: .myTask) {
                NavigationStack {
                    TimelineView(
                        filter: .mine,
                        tasks: $tasks,
                        selectedDate: $selectedDate,
                        onTaskTapped: openTaskDetail,
                        onTaskStatusChanged: persistTaskStatus
                    )
                }
            }

            Tab(AppTab.settings.title, systemImage: AppTab.settings.icon, value: .settings) {
                NavigationStack {
                    SettingsRootView()
                }
            }

            Tab(AppTab.addTask.title, systemImage: AppTab.addTask.icon, value: .addTask, role: .search) {}
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .addTask {
                selectedTab = oldValue
                taskSheetMode = .create
                showTaskSheet = true
            }
        }
        .task(id: reloadToken) {
            await reloadTasks()
        }
        .sheet(isPresented: $showTaskSheet, onDismiss: {
            reloadToken = UUID()
        }) {
            TaskSheetView(mode: .create) { timelineModel in
                Task { await persistTimelineModel(timelineModel) }
            }
        }
        .sheet(isPresented: $showDetailSheet, onDismiss: {
            reloadToken = UUID()
        }) {
            TaskSheetView(
                mode: taskSheetMode,
                onUpdate: { timelineModel in
                    Task { await persistTimelineModel(timelineModel, updating: true) }
                }
            )
        }
    }

    private func openTaskDetail(_ task: TimelineTaskModel) {
        taskSheetMode = .view(task)
        showDetailSheet = true
    }

    private func reloadTasks() async {
        if store == nil {
            store = TimelineStore(
                taskRepository: taskRepository,
                contactRepository: contactRepository
            )
        }
        await store?.load()
        tasks = store?.tasks ?? []
    }

    private func persistTimelineModel(_ timelineModel: TimelineTaskModel, updating: Bool = false) async {
        let careTask = CareTask.from(timelineModel: timelineModel)
        do {
            if updating {
                try await taskRepository.updateTask(careTask)
            } else {
                try await taskRepository.saveTask(careTask)
            }
            await reloadTasks()
        } catch {
            // Milestone 2: surface error to user
        }
    }

    private func persistTaskStatus(_ timelineModel: TimelineTaskModel) {
        Task {
            let careTask = CareTask.from(timelineModel: timelineModel)
            try? await taskRepository.updateTask(careTask)
        }
    }
}

#Preview {
    ContentView()
        .environment(\.contactRepository, AppDependencies.live.contactRepository)
        .environment(\.taskRepository, AppDependencies.live.taskRepository)
        .environment(\.patientRepository, AppDependencies.live.patientRepository)
}
