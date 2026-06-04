//
//  InboxRow.swift
//  CaregiverApp
//
//  A single inbox task request row with profile, details, and Accept/Decline buttons.
//

import SwiftUI

struct InboxRow: View {
    var taskTitle: String = "Hospital Visit"
    var subtitle: String = "27 May 2026"
    var timeRange: String = "09:00-10.30 (2 hr)"
    var hasRepeatBadge: Bool = false
    var onAccept: (() -> Void)? = nil
    var onDecline: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Profile image with wave hand badge
                ZStack(alignment: .bottomTrailing) {
                    Image("profile1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 64)
                        .clipShape(
                            .rect(
                                topLeadingRadius: 16,
                                bottomLeadingRadius: 4,
                                bottomTrailingRadius: 16,
                                topTrailingRadius: 16
                            )
                        )

                    Image(systemName: "hand.raised.fill")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(AppTheme.accentOrange)
                        .clipShape(Circle())
                        .offset(x: 4, y: 4)
                }

                // Task details
                VStack(alignment: .leading, spacing: 3) {
                    Text(taskTitle)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.primaryText)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .foregroundColor(AppTheme.accentOrange)
                        Text(timeRange)
                            .foregroundColor(AppTheme.secondaryText)
                        if hasRepeatBadge {
                            Image(systemName: "arrow.2.squarepath")
                                .foregroundColor(AppTheme.secondaryText)
                        }
                    }
                    .font(.caption)
                }

                Spacer()

                // Accept / Decline icon buttons
                HStack(spacing: 12) {
                    Button(action: { onAccept?() }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.accentBlue)
                    }

                    Button(action: { onDecline?() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()
                .overlay(AppTheme.divider)
                .padding(.leading, 70)
        }
    }
}

#Preview {
    VStack {
        InboxRow()
        InboxRow(taskTitle: "Give Meds", subtitle: "Start from and recurring\n28 May 2026", timeRange: "19:00-19.30 (30 min)", hasRepeatBadge: true)
    }
}
