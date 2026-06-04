//
//  TimelineHeaderSection.swift
//  CaregiverApp
//
//  Header showing date, year, and inbox navigation button.
//

import SwiftUI

struct TimelineHeaderSection: View {
    let selectedDate: Date

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Text(selectedDate.formatted(.dateTime.day().month(.wide)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.accentColor)
                Text(selectedDate.formatted(.dateTime.year()))
                    .font(.title2)
                    .foregroundStyle(AppTheme.secondaryText)
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.accentColor)
            }
            Spacer()

            NavigationLink(destination: InboxView()) {
                Image(systemName: "tray.fill")
                    .font(.title2)
                    .foregroundColor(AppTheme.primaryText)
                    .padding(12)
                    .background(AppTheme.trayIconBackground)
                    .clipShape(Circle())
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(.red)
                            .frame(width: 12, height: 12)
                            .offset(x: 0, y: 0)
                    }
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
}
