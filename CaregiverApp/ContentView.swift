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

    // Task completion popup
    @State private var showCompletionPopup = false
    @State private var completingTask: TimelineTaskModel?

    var body: some View {
        ZStack {
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
                            onTaskStatusChanged: handleTaskStatusChange,
                            onTaskDeleted: handleTaskDeleted
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
                    },
                    onDelete: { taskID in
                        Task {
                            try? await store?.deleteTask(id: taskID)
                            await reloadTasks()
                        }
                    }
                )
            }

            // Task Completion Popup overlay
            if showCompletionPopup, let task = completingTask {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Cancel completion
                        cancelCompletion(task)
                    }

                TaskCompletionPopupView(
                    taskTitle: task.title,
                    onPost: { notes, images in
                        // Post the log and finalize completion
                        finalizeCompletion(task, notes: notes, images: images)
                    },
                    onCancel: {
                        cancelCompletion(task)
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showCompletionPopup)
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
        let assignments = CareTask.assignments(from: timelineModel)
        do {
            if updating {
                try await store?.update(careTask, assignments: assignments)
            } else {
                try await store?.save(careTask, assignments: assignments)
            }
            tasks = store?.tasks ?? []
        } catch {
            // Milestone 2: surface error to user
        }
    }

    /// Called when a task's status changes (accept, decline, toggle complete)
    private func handleTaskStatusChange(_ timelineModel: TimelineTaskModel) {
        // If task was just completed, show the completion popup
        if timelineModel.isCompleted {
            completingTask = timelineModel
            showCompletionPopup = true
        } else {
            // Just persist the status change
            persistTaskStatus(timelineModel)
        }
    }

    /// Called when a task is deleted via swipe
    private func handleTaskDeleted(_ taskID: UUID) {
        Task {
            try? await store?.deleteTask(id: taskID)
            await reloadTasks()
        }
    }

    private func persistTaskStatus(_ timelineModel: TimelineTaskModel) {
        Task {
            let careTask = CareTask.from(timelineModel: timelineModel)
            try? await taskRepository.updateTask(careTask)
        }
    }

    /// Finalize task completion: post log and persist
    private func finalizeCompletion(_ task: TimelineTaskModel, notes: String, images: [UIImage]) {
        showCompletionPopup = false
        completingTask = nil
        // Persist the completed status
        persistTaskStatus(task)
        // TODO: Create a Log entry and post to MainLogView
    }

    /// Cancel task completion: revert the state
    private func cancelCompletion(_ task: TimelineTaskModel) {
        showCompletionPopup = false
        completingTask = nil
        // Revert the task to its previous state
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].state = tasks[index].previousState ?? .assigned
            tasks[index].previousState = nil
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
