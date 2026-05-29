//
//  PatientdetailView.swift
//  CaregiverApp
//

import SwiftUI

struct PatientdetailView: View {
    let patientdetail: CareRecipient

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                patientHeaderCard

                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("Basic Information")
                    infoCard {
                        PatientDetailList(
                            menuName: "Date of Birth",
                            menuImage: "calendar",
                            menuData: patientdetail.dateOfBirthString
                        )
                        Divider().padding(.leading, 28)
                        PatientDetailList(
                            menuName: "Gender",
                            menuImage: "figure.stand",
                            menuData: patientdetail.gender
                        )
                        Divider().padding(.leading, 28)
                        PatientDetailList(
                            menuName: "Blood Type",
                            menuImage: "drop.fill",
                            menuData: patientdetail.bloodType
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    sectionHeader("Health Information")
                    infoCard {
                        PatientDetailList(
                            menuName: "Allergies",
                            menuImage: "bandage.fill",
                            menuData: patientdetail.allergies.isEmpty ? "None listed" : patientdetail.allergies
                        )
                        Divider().padding(.leading, 28)
                        PatientDetailList(
                            menuName: "Favorite Food",
                            menuImage: "fork.knife",
                            menuData: patientdetail.favoriteFood.isEmpty ? "—" : patientdetail.favoriteFood
                        )
                        Divider().padding(.leading, 28)
                        VStack(alignment: .leading, spacing: 8) {
                            PatientDetailList(
                                menuName: "Health Profile",
                                menuImage: "doc.text.fill",
                                menuData: ""
                            )
                            Text(patientdetail.healthNotes)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 28)
                        }
                        .padding(.bottom, 4)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    private var patientHeaderCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 80, height: 80)
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(patientdetail.name)
                    .font(.title2.weight(.semibold))
                Text("\(patientdetail.ageInYears) years old")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Care recipient")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.tint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.accentColor.opacity(0.15)))
            }

            Spacer(minLength: 0)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }

    private func infoCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        PatientdetailView(patientdetail: SeedData.patient)
    }
}
