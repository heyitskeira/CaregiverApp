//
//  TaskSheetView.swift
//  CaregiverApp
//
//  Task detail/creation sheet with custom layout matching the design.
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
    @State private var attachedImages: [UIImage] = []

    private var isCreateMode: Bool {
        if case .create = mode { return true }
        return false
    }

    private var headerTitle: String {
        if isCreateMode {
            return "New Task"
        }
        return "Details"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top Blue Header Section
            VStack(spacing: 0) {
                // Drag indicator
                Capsule()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 36, height: 4)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                
                // Header (X, Details, Checkmark)
                HStack {
                    Button(action: {
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
                    }) {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.black)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text(headerTitle)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        if isEditing {
                            saveTask()
                        } else {
                            isEditing = true
                        }
                    }) {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.bold))
                            .foregroundStyle(.black)
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .disabled(isEditing && taskName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)
                
                // Task Icon & Name
                HStack(alignment: .bottom, spacing: 16) {
                    // Profile picture shape
                    ZStack(alignment: .bottomLeading) {
                        if isEditing {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(width: 60, height: 84)
                                .background(Color.white.opacity(0.2).clipShape(RoundedRectangle(cornerRadius: 16)))
                        } else {
                            // filled leaf shape
                            Color.white.opacity(0.3)
                                .frame(width: 60, height: 84)
                                .clipShape(
                                    .rect(
                                        topLeadingRadius: 16,
                                        bottomLeadingRadius: 4,
                                        bottomTrailingRadius: 16,
                                        topTrailingRadius: 16
                                    )
                                )
                        }
                        
                        // Badge
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 24, height: 24)
                            .background(Color.white.opacity(0.6))
                            .clipShape(Circle())
                            .offset(x: -8, y: 8)
                    }
                    
                    if isEditing {
                        TextField("Task Name", text: $taskName)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.bottom, 4)
                            .overlay(Rectangle().frame(height: 1).foregroundColor(.white), alignment: .bottom)
                    } else {
                        Text(taskName)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.bottom, 4)
                            .overlay(Rectangle().frame(height: 1).foregroundColor(.white), alignment: .bottom)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
            .background(AppTheme.accentBlue)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Date & Time
                    TaskDateTimeSection(
                        isEditing: isEditing,
                        startDate: $taskDate,
                        endDate: $taskEndDate,
                        repeatOption: $repeatOption,
                        onShowCustomRepeat: {
                            showingCustomRepeat = true
                        }
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Separator dash
                    HStack {
                        Text("—")
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)

                    // Assign to
                    TaskAssignSection(
                        isEditing: isEditing,
                        assignedHelpers: $assignedHelpers,
                        availableHelpers: availableHelpers,
                        onShowHelperPicker: {
                            showingHelperPicker = true
                        }
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()
                        .overlay(AppTheme.divider)
                        .padding(.horizontal)

                    // Attachment & Notes
                    TaskAttachmentSection(
                        isEditing: isEditing,
                        taskNote: $taskNote,
                        attachedImages: $attachedImages
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
        }
        .background(AppTheme.pageBackground)
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


    // MARK: - Save
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
