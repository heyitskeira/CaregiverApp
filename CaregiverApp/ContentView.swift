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
    case logPage

    var title: String {
        switch self {
        case .allTask: "All Task"
        case .myTask: "My Task"
        case .settings: "Settings"
        case .addTask: "Add Task"
        case .logPage: "Log"
        }
    }

    var icon: String {
        switch self {
        case .allTask: "list.bullet.rectangle.portrait"
        case .myTask: "person.crop.circle.badge.checkmark"
        case .settings: "gearshape"
        case .addTask: "plus"
        case .logPage: "scroll"
        }
    }
}

struct ContentView: View {
    @Environment(\.taskRepository) private var taskRepository
    @Environment(\.contactRepository) private var contactRepository
    @Environment(\.scenePhase) private var scenePhase
    @Environment(SessionStore.self) private var session

    @State private var selectedTab: AppTab = .allTask
    @State private var showTaskSheet = false
    @State private var selectedDate = Date()
    @State private var taskSheetMode: TaskSheetMode = .create
    @State private var showDetailSheet = false
    @State private var tasks: [TimelineTaskModel] = []
    @State private var store: TimelineStore?
    @State private var reloadToken = UUID()
    @State private var persistErrorMessage: String?

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTab.allTask.title, systemImage: AppTab.allTask.icon, value: AppTab.allTask) {
                NavigationStack {
                    TimelineView(
                        filter: .all,
                        tasks: $tasks,
                        selectedDate: $selectedDate,
                        myTasksAssigneeID: session.currentContactID,
                        onTaskTapped: openTaskDetail,
                        onTaskStatusChanged: persistTaskStatus
                    )
                }
            }

            Tab(AppTab.logPage.title, systemImage: AppTab.logPage.icon, value: AppTab.logPage) {
                NavigationStack {
                    MainLogView()
                }
            }

            Tab(AppTab.myTask.title, systemImage: AppTab.myTask.icon, value: .myTask) {
                NavigationStack {
                    TimelineView(
                        filter: .mine,
                        tasks: $tasks,
                        selectedDate: $selectedDate,
                        myTasksAssigneeID: session.currentContactID,
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
        .onAppear {
            Task { await reloadTasks() }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task { await reloadTasks() }
            }
        }
        .sheet(isPresented: $showTaskSheet) {
            TaskSheetView(mode: .create) { timelineModel in
                await persistTimelineModel(timelineModel)
            }
        }
        .sheet(isPresented: $showDetailSheet) {
            TaskSheetView(
                mode: taskSheetMode,
                onUpdate: { timelineModel in
                    await persistTimelineModel(timelineModel, updating: true)
                }
            )
        }
        .alert("Could Not Save Task", isPresented: Binding(
            get: { persistErrorMessage != nil },
            set: { if !$0 { persistErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(persistErrorMessage ?? "")
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

    private func persistTimelineModel(_ timelineModel: TimelineTaskModel, updating: Bool = false) async -> Bool {
        let careTask = CareTask.from(
            timelineModel: timelineModel,
            careTeamID: session.currentCareTeam.id,
            patientID: session.currentCareTeam.id == SeedData.careTeamID ? SeedData.patientID : SeedData.patientID,
            createdByID: session.currentUser.id
        )
        do {
            if updating {
                try await taskRepository.updateTask(careTask)
            } else {
                try await taskRepository.saveTask(careTask)
            }
            await reloadTasks()
            return true
        } catch {
            persistErrorMessage = "Your task changes could not be saved. Please try again."
            return false
        }
    }

    private func persistTaskStatus(_ timelineModel: TimelineTaskModel) {
        Task {
            let careTask = CareTask.from(
                timelineModel: timelineModel,
                careTeamID: session.currentCareTeam.id,
                createdByID: session.currentUser.id
            )
            try? await taskRepository.updateTask(careTask)
        }
    }
}

#Preview {
    ContentView()
        .environment(SessionStore())
        .environment(\.contactRepository, AppDependencies.live.contactRepository)
        .environment(\.taskRepository, AppDependencies.live.taskRepository)
        .environment(\.patientRepository, AppDependencies.live.patientRepository)
}
