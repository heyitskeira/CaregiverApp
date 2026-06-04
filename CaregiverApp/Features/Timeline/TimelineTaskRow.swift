//
//  TimelineTaskRow.swift
//  CaregiverApp
//
//  A single row in the timeline showing a task with its node, time, and actions.
//

import SwiftUI

struct TimelineTaskRow: View {
    let task: TimelineTaskModel
    let isLast: Bool
    var rowHeight: CGFloat = 80
    var onToggleComplete: (() -> Void)? = nil
    var onAccept: (() -> Void)? = nil
    var onDecline: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil

    private var rowOpacity: Double {
        task.isCompleted ? 0.45 : 1.0
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Time label
            Text(task.startTimeString)
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
                .frame(width: 45, alignment: .trailing)
                .padding(.top, 10)
                .opacity(rowOpacity)

            // Node capsule + connecting line
            VStack(spacing: 0) {
                nodeView
                if !isLast {
                    connectingLine
                }
            }

            // Task info + action buttons
            VStack(alignment: .leading, spacing: 4) {
                taskInfoSection
                if task.showDocumentIcon {
                    Image(systemName: "doc.text.fill")
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
            .padding(.top, 10)
            .opacity(rowOpacity)
            .contentShape(Rectangle())
            .onTapGesture { onTap?() }

            Spacer()

            actionButtons
        }
        .frame(minHeight: rowHeight)
    }

    // MARK: - Node
    @ViewBuilder
    private var nodeView: some View {
        if let initials = task.initials {
            if task.isPending {
                Text(initials)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.secondaryText)
                    .frame(width: 50, height: max(50, rowHeight - 10))
                    .background(AppTheme.cardBackground)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
                            .foregroundColor(AppTheme.secondaryText.opacity(0.6))
                    )
            } else {
                Text(initials)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 50, height: task.isCompleted ? 50 : max(50, rowHeight - 10))
                    .background(task.nodeColor)
                    .clipShape(Capsule())
            }
        } else if let icon = task.iconSystemName {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: max(50, rowHeight - 10))
                .background(task.nodeColor)
                .clipShape(Capsule())
        }
    }

    // MARK: - Connecting Line
    private var connectingLine: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: 2, height: 20)
            .overlay(
                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                    .foregroundColor(task.lineColor)
            )
    }

    // MARK: - Task Info
    private var taskInfoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text("\(task.startTimeString)-\(task.endTimeString) (\(task.durationString))")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)

                if task.hasRepeatIcon {
                    Image(systemName: "arrow.2.squarepath")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }

            Text(task.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.primaryText)
        }
    }

    // MARK: - Action Buttons
    @ViewBuilder
    private var actionButtons: some View {
        if task.isPending || task.isAssigned {
            // Accept / Decline icon buttons
            HStack(spacing: 12) {
                Button(action: { onAccept?() }) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(AppTheme.accentGreen)
                }

                Button(action: { onDecline?() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
            .padding(.top, 10)
        } else {
            // Completion toggle
            Button(action: { onToggleComplete?() }) {
                if task.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.completedNode)
                } else {
                    Circle()
                        .stroke(task.isOngoing
                                ? AppTheme.ongoingNode
                                : AppTheme.assignedNode,
                                lineWidth: 3)
                        .frame(width: 22, height: 22)
                }
            }
            .padding(.top, 10)
        }
    }
}
