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

enum RepeatUnit: String, CaseIterable {
    case days = "Days"
    case weeks = "Weeks"
    case months = "Months"
    case years = "Years"
}

struct TaskSheetView: View {
    
    @State private var assignedContacts: [CareContact] = []
    @State private var showingHelperPicker = false
    
    @Environment(\.dismiss) private var dismiss
    
    //Task Title
    @State private var taskName: String = ""
    @State private var taskNote: String = ""
    
    //Task Date
    @State private var taskDate = Date()
    
    //Task Repitition
    @State private var repeatOption: RepeatOption = .none

    @State private var showingCustomRepeat = false

    @State private var repeatInterval = 1

    @State private var repeatUnit: RepeatUnit = .weeks
    
    private var customRepeatText: String {
        "Every \(repeatInterval) \(repeatUnit.rawValue)"
    }
    
    var body: some View {
        NavigationStack{
            Form{
                //Text Field for Task Name
                Section("Task Name") {
                    TextField(
                        "e.g., Change poopie pants",
                        text: $taskName
                    )
                }
                
                //Per View would have a Title, then the Main Function
                
                //Assign People
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
                
                //Date & Time
                Section("Schedule"){
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
                
                //Reapetition Choice
                Section("Repeat") {
                    Menu {
                        ForEach(RepeatOption.allCases.filter { $0 != .custom }  , id: \.self) { option in
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
                
                //Text Field for Notes
                Section("Notes for Helper"){
                    TextField(
                        "e.g., Poopie first then pants",
                        text: $taskNote
                    )
                }
            }
            //Sticky Title (Task Name)
            .navigationTitle(
                taskName.isEmpty
                ? "New Task"
                : String(taskName.prefix(25))
            )
            .navigationBarTitleDisplayMode(.inline)
            
            //Cancel & Done Button
            .toolbar{
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
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
    
}


#Preview {
    TaskSheetView()
        .environment(\.contactRepository, AppDependencies.live.contactRepository)
}
