//
//  CurrentTimeIndicator.swift
//  CaregiverApp
//
//  Red time pill + line indicator showing current time on the timeline.
//

import SwiftUI

struct CurrentTimeIndicator: View {
    var currentTime: Date

    private var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: currentTime)
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(timeString)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.red)
                .clipShape(Capsule())
                .padding(.leading, 8)

            Rectangle()
                .fill(Color.red)
                .frame(height: 1.5)
                .padding(.trailing, 24)
        }
    }
}
