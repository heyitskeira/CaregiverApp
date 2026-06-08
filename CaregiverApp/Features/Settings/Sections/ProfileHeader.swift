//
//  ProfileHeader.swift
//  CaregiverApp
//
//  Created by Dzikry Aji Santoso on 08/06/26.
//

import SwiftUI

struct ProfileHeader: View {
    @State var title: String
    @State var subTitle: String

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.bold))

                Text(subTitle)
                    .font(.footnote)
                    .foregroundStyle(Color.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(30)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ProfileHeader(title: "Sarah Antoso", subTitle: "Primary Caregiver")
}
