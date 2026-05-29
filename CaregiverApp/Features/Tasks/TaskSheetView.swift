//
//  TaskSheetView.swift
//  CaregiverApp
//
//  Created by Christopher Jonathan on 27/05/26.
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

struct Helper: Identifiable {
    let id = UUID()

    let name: String
    let phoneNumber: String
    let role: String
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
    var onSave: ((TimelineTaskModel) -> Void)?
    var onUpdate: ((TimelineTaskModel) -> Void)?

    init(
        mode: TaskSheetMode = .create,
        onSave: ((TimelineTaskModel) -> Void)? = nil,
        onUpdate: ((TimelineTaskModel) -> Void)? = nil
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
        case .view(let task):
            _taskName = State(initialValue: task.title)
            _taskNote = State(initialValue: task.taskNote)
            _taskDate = State(initialValue: task.startDate)
            _taskEndDate = State(initialValue: task.endDate)
            _repeatOption = State(initialValue: task.repeatOption)
            _isEditing = State(initialValue: false)
            _editingTaskId = State(initialValue: task.id)
        case .edit(let task):
            _taskName = State(initialValue: task.title)
            _taskNote = State(initialValue: task.taskNote)
            _taskDate = State(initialValue: task.startDate)
            _taskEndDate = State(initialValue: task.endDate)
            _repeatOption = State(initialValue: task.repeatOption)
            _isEditing = State(initialValue: true)
            _editingTaskId = State(initialValue: task.id)
        }
    }

    @State private var assignedHelpers: [Helper] = []

    private let availableHelpers: [Helper] = [
        Helper(
            name: "Sarah Johnson",
            phoneNumber: "+1 (555) 123-4567",
            role: "Primary Caregiver"
        ),
        Helper(
            name: "Michael Johnson",
            phoneNumber: "+1 (555) 987-6543",
            role: "Substitute Helper"
        ),
        Helper(
            name: "Emma Johnson",
            phoneNumber: "+1 (555) 246-8100",
            role: "Backup"
        )
    ]

    @State private var showingHelperPicker = false

    @Environment(\.dismiss) private var dismiss

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
                        TextField(
                            "e.g., Change poopie pants",
                            text: $taskName
                        )
                    } else {
                        Text(taskName)
                            .foregroundStyle(.primary)
                    }
                }

                Section("Assign") {
                    ForEach(assignedHelpers, id: \.phoneNumber) { helper in
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 40))

                            VStack(alignment: .leading) {
                                Text(helper.name)

                                Text(helper.phoneNumber)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text(helper.role)
                                    .font(.caption2)
                                    .foregroundStyle(.blue)
                            }

                            Spacer()

                            if isEditing {
                                Button {
                                    assignedHelpers.removeAll {
                                        $0.phoneNumber == helper.phoneNumber
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.red)
                                }
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
                        DatePicker(
                            "Start",
                            selection: $taskDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)

                        DatePicker(
                            "End",
                            selection: $taskEndDate,
                            in: taskDate...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
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
                                Text(
                                    repeatOption == .custom
                                    ? customRepeatText
                                    : repeatOption.rawValue
                                )

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        HStack {
                            Text("Repeat")
                            Spacer()
                            Text(
                                repeatOption == .custom
                                ? customRepeatText
                                : repeatOption.rawValue
                            )
                            .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Notes for Helper") {
                    if isEditing {
                        TextField(
                            "e.g., Poopie first then pants",
                            text: $taskNote
                        )
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
                        if isEditing && !isCreateMode {
                            if case .view(let task) = mode {
                                taskName = task.title
                                taskNote = task.taskNote
                                taskDate = task.startDate
                                taskEndDate = task.endDate
                                repeatOption = task.repeatOption
                            }
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
                            saveTask()
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                        .disabled(taskName.trimmingCharacters(in: .whitespaces).isEmpty)
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                        .foregroundStyle(.blue)
                    }
                }
            }
        }
        .sheet(isPresented: $showingHelperPicker) {
            HelperPickerView(
                availableHelpers: availableHelpers
            ) { helper in
                if !assignedHelpers.contains(where: {
                    $0.phoneNumber == helper.phoneNumber
                }) {
                    assignedHelpers.append(helper)
                }
            }
        }
        .sheet(isPresented: $showingCustomRepeat) {
            CustomRepeatView(
                repeatInterval: $repeatInterval,
                repeatUnit: $repeatUnit
            )
        }
    }

    private var navigationTitle: String {
        if isCreateMode {
            return taskName.isEmpty ? "New Task" : String(taskName.prefix(25))
        } else {
            return String(taskName.prefix(25))
        }
    }

    private func saveTask() {
        if isCreateMode {
            let initials = assignedHelpers.first.map { helper in
                let parts = helper.name.split(separator: " ")
                return parts.map { String($0.prefix(1)) }.joined()
            } ?? "AA"

            let newTask = TimelineTaskModel(
                startDate: taskDate,
                endDate: taskEndDate,
                title: taskName,
                initials: initials,
                hasRepeatIcon: repeatOption != .none,
                state: .assigned,
                taskNote: taskNote,
                repeatOption: repeatOption
            )
            onSave?(newTask)
        } else if let taskId = editingTaskId {
            var updated = TimelineTaskModel(
                id: taskId,
                startDate: taskDate,
                endDate: taskEndDate,
                title: taskName,
                hasRepeatIcon: repeatOption != .none,
                state: .assigned,
                taskNote: taskNote,
                repeatOption: repeatOption
            )
            if let firstHelper = assignedHelpers.first {
                let parts = firstHelper.name.split(separator: " ")
                updated.initials = parts.map { String($0.prefix(1)) }.joined()
            }
            onUpdate?(updated)
        }
        dismiss()
    }
}


#Preview {
    TaskSheetView()
}
