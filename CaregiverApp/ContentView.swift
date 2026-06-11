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
        case .timeline: "calendar.day.timeline.left"
        case .logPage: "text.book.closed.fill"
        case .profile: "person.crop.circle"
        case .addTask: "plus"
        }
    }
}

struct ContentView: View {
    @Environment(\.taskRepository) private var taskRepository
    @Environment(\.contactRepository) private var contactRepository
    @Environment(\.authService) private var authService
    @Environment(\.logRepository) private var logRepository

    @State private var selectedTab: AppTab = .timeline
    @State private var showTaskSheet = false
    @State private var selectedDate = Date()
    @State private var taskSheetMode: TaskSheetMode = .create
    @State private var showDetailSheet = false
    @State private var tasks: [TimelineTaskModel] = []
    @State private var store: TimelineStore?
    @State private var reloadToken = UUID()

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
                } else if newValue == .timeline {
                    reloadToken = UUID()
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

            if showCompletionPopup, let task = completingTask {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        cancelCompletion(task)
                    }

                TaskCompletionPopupView(
                    taskTitle: task.title,
                    onPost: { notes, images in
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
            
        }
    }

    private func handleTaskStatusChange(_ timelineModel: TimelineTaskModel) {
        if timelineModel.isCompleted {
            completingTask = timelineModel
            showCompletionPopup = true
        } else {
            persistTaskStatus(timelineModel)
        }
    }

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

    private func finalizeCompletion(_ task: TimelineTaskModel, notes: String, images: [UIImage]) {
        showCompletionPopup = false
        completingTask = nil
        persistTaskStatus(task)

        Task {
            let user = authService.currentUser
            let authorContact = CareContact(
                id: user?.id ?? UUID(),
                careTeamID: SeedData.careTeamID,
                name: user?.name ?? "Caregiver",
                relationship: authService.currentRole == .primaryCaregiver ? "Primary Caregiver" : "Helper",
                phone: user?.phone ?? "",
                email: user?.email ?? ""
            )
            let logContent = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "✅ Completed: \(task.title)"
                : "✅ Completed: \(task.title) — \(notes)"
            let newLog = Log(
                author: authorContact,
                content: logContent,
                images: images
            )
            try? await logRepository.saveLog(newLog)
        }
    }

    private func cancelCompletion(_ task: TimelineTaskModel) {
        showCompletionPopup = false
        completingTask = nil
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
        .environment(\.logRepository, AppDependencies.live.logRepository)
        .environment(AppRouter())
}
