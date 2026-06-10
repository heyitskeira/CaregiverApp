//
//  TaskSheetView.swift
//  CaregiverApp
//

import SwiftUI

enum RepeatOption: String, CaseIterable {
    case none = "Does not repeat"
    case daily = "Every day"
    case weekly = "Every week"
    case monthly = "Every month"
    case yearly = "Every year"
    case custom = "Custom"
}

enum RepeatUnit: String, CaseIterable {
    case days = "Days"
    case weeks = "Weeks"
    case months = "Months"
    case years = "Years"
}

enum TaskSheetMode {
    case create
    case view(TimelineTaskModel)
    case edit(TimelineTaskModel)
}

struct TaskSheetView: View {
    var mode: TaskSheetMode
    var onSave: ((TimelineTaskModel) async -> Bool)?
    var onUpdate: ((TimelineTaskModel) async -> Bool)?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.contactRepository) private var contactRepository

    @State private var assignedContacts: [CareContact] = []
    @State private var showingHelperPicker = false
    @State private var taskName: String
    @State private var taskNote: String
    @State private var taskDate: Date
    @State private var taskEndDate: Date
    @State private var repeatOption: RepeatOption
    @State private var showingCustomRepeat = false
    @State private var repeatInterval = 1
    @State private var repeatUnit: RepeatUnit = .weeks
    @State private var isEditing: Bool
    @State private var editingTaskId: UUID?
    @State private var editingAssigneeIDs: [UUID] = []

    init(
        mode: TaskSheetMode = .create,
        onSave: ((TimelineTaskModel) async -> Bool)? = nil,
        onUpdate: ((TimelineTaskModel) async -> Bool)? = nil
    ) {
        self.mode = mode
        self.onSave = onSave
        self.onUpdate = onUpdate

        switch mode {
        case .create:
            _taskName = State(initialValue: "")
            _taskNote = State(initialValue: "")
            _taskDate = State(initialValue: Date())
            _taskEndDate = State(initialValue: Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date())
            _repeatOption = State(initialValue: .none)
            _isEditing = State(initialValue: true)
            _editingTaskId = State(initialValue: nil)
        case .view(let task), .edit(let task):
            _taskName = State(initialValue: task.title)
            _taskNote = State(initialValue: task.taskNote)
            _taskDate = State(initialValue: task.startDate)
            _taskEndDate = State(initialValue: task.endDate)
            _repeatOption = State(initialValue: task.repeatOption)
            _repeatInterval = State(initialValue: task.repeatInterval)
            _repeatUnit = State(initialValue: task.repeatUnit)
            _isEditing = State(initialValue: {
                if case .edit = mode { return true }
                return false
            }())
            _editingTaskId = State(initialValue: task.id)
            _editingAssigneeIDs = State(initialValue: task.assigneeIDs)
        }
    }

    private var isCreateMode: Bool {
        if case .create = mode { return true }
        return false
    }

    private var customRepeatText: String {
        "Every \(repeatInterval) \(repeatUnit.rawValue)"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Name") {
                    if isEditing {
                        TextField("e.g., Change poopie pants", text: $taskName)
                    } else {
                        Text(taskName)
                    }
                }

                Section("Assign") {
                    ForEach(assignedContacts) { contact in
                        HStack(spacing: 12) {
                            ContactAvatarView(contact: contact, size: 40)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(contact.name)
                                if !contact.phone.isEmpty {
                                    Text(contact.phone)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text(contact.relationship)
                                    .font(.caption2)
                                    .foregroundStyle(.tint)
                            }

                            Spacer()

                            if isEditing {
                                Button {
                                    assignedContacts.removeAll { $0.id == contact.id }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.red)
                                }
                                .accessibilityLabel("Remove \(contact.name)")
                            }
                        }
                    }

                    if isEditing {
                        Button {
                            showingHelperPicker = true
                        } label: {
                            Label("Add Helper", systemImage: "plus.circle.fill")
                        }
                    }
                }

                Section("Schedule") {
                    if isEditing {
                        DatePicker("Start", selection: $taskDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                        DatePicker("End", selection: $taskEndDate, in: taskDate..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                    } else {
                        HStack {
                            Text("Start")
                            Spacer()
                            Text(taskDate.formatted(date: .abbreviated, time: .shortened))
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("End")
                            Spacer()
                            Text(taskEndDate.formatted(date: .abbreviated, time: .shortened))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Repeat") {
                    if isEditing {
                        Menu {
                            ForEach(RepeatOption.allCases.filter { $0 != .custom }, id: \.self) { option in
                                Button {
                                    repeatOption = option
                                } label: {
                                    if repeatOption == option {
                                        Label(option.rawValue, systemImage: "checkmark")
                                    } else {
                                        Text(option.rawValue)
                                    }
                                }
                            }

                            Divider()

                            Button {
                                repeatOption = .custom
                                showingCustomRepeat = true
                            } label: {
                                if repeatOption == .custom {
                                    Label("Custom...", systemImage: "checkmark")
                                } else {
                                    Text("Custom...")
                                }
                            }
                        } label: {
                            HStack {
                                Text(repeatOption == .custom ? customRepeatText : repeatOption.rawValue)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        HStack {
                            Text("Repeat")
                            Spacer()
                            Text(repeatOption == .custom ? customRepeatText : repeatOption.rawValue)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Notes for Helper") {
                    if isEditing {
                        TextField("e.g., Poopie first then pants", text: $taskNote)
                    } else {
                        Text(taskNote.isEmpty ? "No notes" : taskNote)
                            .foregroundStyle(taskNote.isEmpty ? .secondary : .primary)
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(isEditing && !isCreateMode ? "Cancel" : "Close") {
                        if isEditing && !isCreateMode, case .view(let task) = mode {
                            taskName = task.title
                            taskNote = task.taskNote
                            taskDate = task.startDate
                            taskEndDate = task.endDate
                            repeatOption = task.repeatOption
                            repeatInterval = task.repeatInterval
                            repeatUnit = task.repeatUnit
                            editingAssigneeIDs = task.assigneeIDs
                            Task { await loadAssignedContacts() }
                            isEditing = false
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundStyle(.blue)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing {
                        Button("Save") {
                            Task { await saveTask() }
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                        .disabled(taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                        .foregroundStyle(.blue)
                    }
                }
            }
            .task {
                await loadAssignedContacts()
            }
        }
        .sheet(isPresented: $showingHelperPicker) {
            HelperPickerView(
                excludedContactIDs: Set(assignedContacts.map(\.id))
            ) { contact in
                if !assignedContacts.contains(where: { $0.id == contact.id }) {
                    assignedContacts.append(contact)
                }
            }
        }
        .sheet(isPresented: $showingCustomRepeat) {
            CustomRepeatView(repeatInterval: $repeatInterval, repeatUnit: $repeatUnit)
        }
    }

    private var navigationTitle: String {
        if isCreateMode {
            return taskName.isEmpty ? "New Task" : String(taskName.prefix(25))
        }
        return String(taskName.prefix(25))
    }

    private func loadAssignedContacts() async {
        guard !editingAssigneeIDs.isEmpty else {
            assignedContacts = []
            return
        }
        var loaded: [CareContact] = []
        for id in editingAssigneeIDs {
            if let contact = try? await contactRepository.contact(id: id) {
                loaded.append(contact)
            }
        }
        assignedContacts = loaded
    }

    private func saveTask() async {
        let assigneeIDs = assignedContacts.map(\.id)
        let initials = assignedContacts.first?.initials

        let timelineModel = TimelineTaskModel(
            id: editingTaskId ?? UUID(),
            startDate: taskDate,
            endDate: taskEndDate,
            title: taskName.trimmingCharacters(in: .whitespacesAndNewlines),
            initials: initials,
            hasRepeatIcon: repeatOption != .none,
            state: assigneeIDs.isEmpty ? .pending : .assigned,
            taskNote: taskNote.trimmingCharacters(in: .whitespacesAndNewlines),
            repeatOption: repeatOption,
            repeatInterval: repeatInterval,
            repeatUnit: repeatUnit,
            assigneeIDs: assigneeIDs
        )

        let saved: Bool
        if isCreateMode {
            saved = await onSave?(timelineModel) ?? true
        } else {
            saved = await onUpdate?(timelineModel) ?? true
        }
        if saved {
            dismiss()
        }
    }
}

#Preview {
    TaskSheetView()
        .environment(\.contactRepository, AppDependencies.live.contactRepository)
        .environment(\.taskRepository, AppDependencies.live.taskRepository)
}
