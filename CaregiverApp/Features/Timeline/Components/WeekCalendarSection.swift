//
//  WeekCalendarSection.swift
//  CaregiverApp
//
//  Horizontal week calendar strip showing Sun-Sat with selected day highlight.
//

import SwiftUI

struct WeekCalendarSection: View {
    @Binding var selectedDate: Date

    private var calendar: Calendar { Calendar.current }

    private func weekDates(around date: Date) -> [Date] {
        let weekday = calendar.component(.weekday, from: date)
        let sundayOffset = -(weekday - 1)
        guard let sunday = calendar.date(byAdding: .day, value: sundayOffset, to: date) else {
            return []
        }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: sunday) }
    }

    var body: some View {
        HStack {
            let week = weekDates(around: selectedDate)
            let dayFormatter: DateFormatter = {
                let f = DateFormatter()
                f.dateFormat = "EEE"
                return f
            }()

            ForEach(week, id: \.self) { day in
                let isSelected = calendar.isDate(day, inSameDayAs: selectedDate)
                let isToday = calendar.isDateInToday(day)

                Button(action: {
                    selectedDate = day
                }) {
                    VStack(spacing: 8) {
                        Text(dayFormatter.string(from: day).uppercased())
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.secondaryText)

                        Text("\(calendar.component(.day, from: day))")
                            .font(.headline)
                            .fontWeight(isSelected ? .bold : .semibold)
                            .foregroundStyle(isSelected ? .white : (isToday ? Color.accentColor : AppTheme.primaryText))
                            .frame(width: 36, height: 36)
                            .background {
                                if isSelected {
                                    Circle().fill(Color.accentColor)
                                }
                            }
                    }
                }
                .buttonStyle(.plain)
                if day != week.last { Spacer() }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
}
