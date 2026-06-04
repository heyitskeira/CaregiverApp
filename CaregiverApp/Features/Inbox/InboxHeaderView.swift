//
//  InboxHeaderView.swift
//  CaregiverApp
//
//  Task request summary banner with wave-hand icon and "Accept All" button.
//

import SwiftUI

struct InboxHeaderView: View {
    let requestCount: Int
    var onAcceptAll: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "hand.wave.fill")
                .foregroundColor(.white)
                .font(.body)
                .frame(width: 40, height: 40)
                .background(AppTheme.accentOrange)
                .clipShape(Circle())

            Text("\(requestCount) task request")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.primaryText)

            Spacer()

            Button(action: { onAcceptAll?() }) {
                Text("Accept All")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppTheme.assignedNode)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}
