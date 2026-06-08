//
//  PatientDetailList.swift
//  CaregiverApp
//
//  Created by Keira on 28/05/26.
//
import SwiftUI

struct PatientDetailList: View {

    var menuName: String
    var menuImage: String
    var menuData: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.accent.opacity(0.2))
                .frame(width: 35, height: 35)
                .overlay(
                    Image(systemName: menuImage)
                        .foregroundColor(.accent)
                        .font(.system(size: 20))
                )

            Text(menuName)

            Spacer()

            Text(menuData)
        }
    }
}

#Preview {
    PatientDetailList(
        menuName: "Allergies",
        menuImage: "exclamationmark.square.fill",
        menuData: "alergi"
    )
}
