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

struct TaskSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.taskRepository) private var taskRepository

    @State private var assignedContacts: [CareContact] = []
    @State private var showingHelperPicker = false
    @State private var taskName = ""
    @State private var taskNote = ""
    @State private var taskDate = Date()
    @State private var repeatOption: RepeatOption = .none
    @State private var showingCustomRepeat = false
    @State private var repeatInterval = 1
    @State private var repeatUnit: RepeatUnit = .weeks
    @State private var isSaving = false

    private var customRepeatText: String {
        "Every \(repeatInterval) \(repeatUnit.rawValue)"
    }

    private var canSave: Bool {
        !taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSaving
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Name") {
                    TextField(
                        "e.g., Change poopie pants",
                        text: $taskName
                    )
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

                            Button {
                                assignedContacts.removeAll { $0.id == contact.id }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            .accessibilityLabel("Remove \(contact.name)")
                        }
                    }
                    Button {
                        showingHelperPicker = true
                    } label: {
                        Label("Add Helper", systemImage: "plus.circle.fill")
                    }
                }

                Section("Schedule") {
                    DatePicker(
                        "Pick a Date",
                        selection: $taskDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)

                    DatePicker(
                        "Time",
                        selection: $taskDate,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .frame(height: 120)
                }

                Section("Repeat") {
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
                }

                Section("Notes for Helper") {
                    TextField(
                        "e.g., Poopie first then pants",
                        text: $taskNote
                    )
                }
            }
            .navigationTitle(
                taskName.isEmpty
                ? "New Task"
                : String(taskName.prefix(25))
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task { await save() }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
                    .disabled(!canSave)
                }
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
            CustomRepeatView(
                repeatInterval: $repeatInterval,
                repeatUnit: $repeatUnit
            )
        }
    }

    private func save() async {
        let trimmedTitle = taskName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        isSaving = true
        defer { isSaving = false }

        let assigneeIDs = assignedContacts.map(\.id)
        let task = CareTask(
            title: trimmedTitle,
            scheduledAt: taskDate,
            durationMinutes: 30,
            instructions: taskNote.trimmingCharacters(in: .whitespacesAndNewlines),
            careTeamID: SeedData.careTeamID,
            patientID: SeedData.patientID,
            assigneeIDs: assigneeIDs,
            recurrence: TaskRecurrence.from(
                repeatOption: repeatOption,
                interval: repeatInterval,
                unit: repeatUnit
            ),
            createdByID: SeedData.primaryCaregiverID
        )

        do {
            try await taskRepository.saveTask(task)
            dismiss()
        } catch {
            // Keep sheet open on failure; Milestone 2 can surface an alert.
        }
    }
}

#Preview {
    TaskSheetView()
        .environment(\.contactRepository, AppDependencies.live.contactRepository)
        .environment(\.taskRepository, AppDependencies.live.taskRepository)
}
