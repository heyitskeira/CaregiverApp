//
//  InboxView.swift
//  CaregiverApp
//
//  Inbox view showing pending task requests with accept/decline actions.
//

import SwiftUI

struct InboxView: View {
    @Environment(\.dismiss) private var dismiss

    private let inboxItems: [(title: String, subtitle: String, time: String, hasRepeat: Bool)] = [
        ("Hospital Visit", "27 May 2026", "09:00-10.30 (2 hr)", false),
        ("Give Meds", "Start from and recurring\n28 May 2026", "19:00-19.30 (30 min)", true),
        ("Hospital Visit", "27 May 2026", "05:00-05.30 (30 min)", false),
        ("Hospital Visit", "27 May 2026", "05:00-06.30 (30 min)", false),
        ("Hospital Visit", "27 May 2026", "05:00-05.30 (30 min)", false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Back button
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.primaryText)
                        .padding(12)
                        .background(AppTheme.cardBackground)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)

            // Title
            HStack {
                Text("Inbox")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)

            Divider()
                .overlay(AppTheme.divider)
                .padding(.vertical, 10)

            // Content
            ScrollView {
                VStack(spacing: 0) {
                    InboxHeaderView(requestCount: inboxItems.count)
                        .padding(.bottom, 8)

                    ForEach(Array(inboxItems.enumerated()), id: \.offset) { _, item in
                        InboxRow(
                            taskTitle: item.title,
                            subtitle: item.subtitle,
                            timeRange: item.time,
                            hasRepeatBadge: item.hasRepeat
                        )
                    }
                }
            }
        }
        .background(AppTheme.pageBackground)
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        InboxView()
    }
}
