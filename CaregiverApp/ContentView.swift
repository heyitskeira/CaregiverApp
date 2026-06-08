//
//  ContentView.swift
//  CaregiverApp
//

import SwiftUI

enum AppTab: String, CaseIterable {
    case timeline
    case logPage
    case profile
    case addTask

    var title: String {
        switch self {
        case .timeline: "Timeline"
        case .logPage: "Logs"
        case .profile: "Profile"
        case .addTask: "Add Task"
        }
    }

    var icon: String {
        switch self {
        case .timeline: "list.bullet.rectangle.portrait"
        case .logPage: "doc.text"
        case .profile: "person.crop.circle"
        case .addTask: "plus"
        }
    }
}

struct ContentView: View {
    @Environment(\.taskRepository) private var taskRepository
    @Environment(\.contactRepository) private var contactRepository
    @Environment(\.authService) private var authService

    @State private var selectedTab: AppTab = .timeline
    @State private var showTaskSheet = false
    @State private var selectedDate = Date()
    @State private var taskSheetMode: TaskSheetMode = .create
    @State private var showDetailSheet = false
    @State private var tasks: [TimelineTaskModel] = []
    @State private var store: TimelineStore?
    @State private var reloadToken = UUID()

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(
                AppTab.timeline.title,
                systemImage: AppTab.timeline.icon,
                value: .timeline
            ) {
                NavigationStack {
                    TimelineView(
                        tasks: $tasks,
                        selectedDate: $selectedDate,
                        onTaskTapped: openTaskDetail,
                        onTaskStatusChanged: persistTaskStatus
                    )
                }
            }

            Tab(
                AppTab.logPage.title,
                systemImage: AppTab.logPage.icon,
                value: .logPage
            ) {
                NavigationStack {
                    MainLogView()
                }
            }

            Tab(
                AppTab.profile.title,
                systemImage: AppTab.profile.icon,
                value: .profile
            ) {
                ProfileRootView()
            }

            if authService.currentRole.canCreateTask {
                Tab(
                    AppTab.addTask.title,
                    systemImage: AppTab.addTask.icon,
                    value: .addTask,
                    role: .search
                ) {}
            }
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
        .sheet(
            isPresented: $showTaskSheet,
            onDismiss: {
                reloadToken = UUID()
            }
        ) {
            TaskSheetView(mode: .create) { timelineModel in
                Task { await persistTimelineModel(timelineModel) }
            }
        }
        .sheet(
            isPresented: $showDetailSheet,
            onDismiss: {
                reloadToken = UUID()
            }
        ) {
            TaskSheetView(
                mode: taskSheetMode,
                onUpdate: { timelineModel in
                    Task {
                        await persistTimelineModel(
                            timelineModel,
                            updating: true
                        )
                    }
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

    private func persistTimelineModel(
        _ timelineModel: TimelineTaskModel,
        updating: Bool = false
    ) async {
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
        .environment(
            \.contactRepository,
            AppDependencies.live.contactRepository
        )
        .environment(\.taskRepository, AppDependencies.live.taskRepository)
        .environment(
            \.patientRepository,
            AppDependencies.live.patientRepository
        )
}
