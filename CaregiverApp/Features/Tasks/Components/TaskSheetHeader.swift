//
//  TaskSheetHeader.swift
//  CaregiverApp
//
//  Custom header for the task sheet with close, title, and save/confirm buttons.
//

import SwiftUI

struct TaskSheetHeader: View {
    let title: String
    let isEditing: Bool
    var onClose: (() -> Void)? = nil
    var onSave: (() -> Void)? = nil
    var isSaveDisabled: Bool = false

    var body: some View {
        ZStack {
            // Center title
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.primaryText)

            HStack {
                // Close / Cancel button
                Button(action: { onClose?() }) {
                    Image(systemName: "xmark")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.primaryText)
                        .frame(width: 36, height: 36)
                        .background(AppTheme.trayIconBackground)
                        .clipShape(Circle())
                }

                Spacer()

                // Save / Confirm button
                Button(action: { onSave?() }) {
                    Image(systemName: "checkmark")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundStyle(isSaveDisabled ? AppTheme.secondaryText : AppTheme.accentGreen)
                        .frame(width: 36, height: 36)
                        .background(AppTheme.trayIconBackground)
                        .clipShape(Circle())
                }
                .disabled(isSaveDisabled)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}
