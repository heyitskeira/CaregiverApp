//
//  TaskAssignSection.swift
//  CaregiverApp
//
//  Assign-to section for the task sheet showing assigned helpers or empty state.
//

import SwiftUI

struct TaskAssignSection: View {
    let isEditing: Bool
    @Binding var assignedHelpers: [Helper]
    let availableHelpers: [Helper]
    var onShowHelperPicker: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Assign to")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.primaryText)
                .padding(.horizontal)
                .padding(.bottom, 12)

            if assignedHelpers.isEmpty {
                // Empty state
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle")
                        .font(.title2)
                        .foregroundStyle(AppTheme.secondaryText)

                    Text("This task has not been assigned yet..")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                        .italic()

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    if isEditing {
                        onShowHelperPicker?()
                    }
                }
            } else {
                ForEach(assignedHelpers, id: \.phoneNumber) { helper in
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(AppTheme.secondaryText)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(helper.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(AppTheme.primaryText)

                            Text(helper.role)
                                .font(.caption)
                                .foregroundStyle(Color.accentColor)
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
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                }

                if isEditing {
                    Button {
                        onShowHelperPicker?()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(Color.accentColor)
                            Text("Add Helper")
                                .font(.subheadline)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
        }
    }
}
