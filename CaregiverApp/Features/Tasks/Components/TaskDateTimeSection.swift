//
//  TaskDateTimeSection.swift
//  CaregiverApp
//
//  Date & Time section for the task sheet with time, date, and repeat rows.
//

import SwiftUI

struct TaskDateTimeSection: View {
    let isEditing: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var repeatOption: RepeatOption
    var onShowCustomRepeat: (() -> Void)? = nil

    private var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "HH.mm"
        let start = f.string(from: startDate)
        let end = f.string(from: endDate)
        return "\(start)-\(end)"
    }

    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "dd MMMM yyyy"
        return f.string(from: startDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header
            Text("Date & Time")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.primaryText)
                .padding(.horizontal)
                .padding(.bottom, 12)

            if isEditing {
                editableContent
            } else {
                readOnlyContent
            }
        }
    }

    // MARK: - Read Only
    private var readOnlyContent: some View {
        VStack(spacing: 0) {
            // Time row
            rowView(
                icon: "clock",
                label: "Time",
                value: timeString,
                showChevron: true
            )

            Divider()
                .overlay(AppTheme.divider)
                .padding(.leading, 52)

            // Date row
            rowView(
                icon: "calendar",
                label: "Date",
                value: dateString,
                showChevron: true
            )

            Divider()
                .overlay(AppTheme.divider)
                .padding(.leading, 52)

            // Repeat row
            rowView(
                icon: "arrow.2.squarepath",
                label: repeatOption == .none ? "Does not Repeat" : repeatOption.rawValue,
                value: nil,
                showChevron: true
            )
        }
    }

    // MARK: - Editable
    private var editableContent: some View {
        VStack(spacing: 12) {
            // Start time picker
            HStack(spacing: 12) {
                Image(systemName: "clock")
                    .font(.body)
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(width: 24)

                DatePicker(
                    "Start",
                    selection: $startDate,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.compact)
            }
            .padding(.horizontal)

            // End time picker
            HStack(spacing: 12) {
                Color.clear.frame(width: 24, height: 1)

                DatePicker(
                    "End",
                    selection: $endDate,
                    in: startDate...,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.compact)
            }
            .padding(.horizontal)

            Divider()
                .overlay(AppTheme.divider)
                .padding(.leading, 52)

            // Date picker
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.body)
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(width: 24)

                DatePicker(
                    "Date",
                    selection: $startDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
            }
            .padding(.horizontal)

            Divider()
                .overlay(AppTheme.divider)
                .padding(.leading, 52)

            // Repeat picker
            HStack(spacing: 12) {
                Image(systemName: "arrow.2.squarepath")
                    .font(.body)
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(width: 24)

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
                        onShowCustomRepeat?()
                    } label: {
                        Text("Custom...")
                    }
                } label: {
                    HStack {
                        Text(repeatOption == .none ? "Does not Repeat" : repeatOption.rawValue)
                            .foregroundStyle(AppTheme.primaryText)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Row Helper
    private func rowView(icon: String, label: String, value: String?, showChevron: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(AppTheme.secondaryText)
                .frame(width: 24)

            Text(label)
                .font(.body)
                .foregroundStyle(AppTheme.primaryText)

            Spacer()

            if let value = value {
                Text(value)
                    .font(.body)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}
