//
//  PatientdetailView.swift
//  CaregiverApp
//
//  Patient detail view showing profile, basic information, and health details.
//

import SwiftUI

struct PatientdetailView: View {
    @Environment(\.patientRepository) private var patientRepository

    @State var patientdetail: CareRecipient
    @State private var isShowingEditView = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Patient")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.primaryText)

                    Spacer()

                    Button(action: {
                        isShowingEditView = true
                    }) {
                        Text("Edit")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color.accentColor)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Patient card
                HStack(spacing: 14) {
                    Image("profile1")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(patientdetail.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.primaryText)

                        Text("\(patientdetail.ageInYears) Years Old")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText)
                    }

                    Spacer()
                }
                .padding()
                .background(Color.accentColor.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
                .padding(.top, 16)

                // Basic Information
                infoSection(title: "Basic Information") {
                    infoRow(icon: "calendar", label: "Date of Birth", value: patientdetail.dateOfBirthString)
                    sectionDivider
                    infoRow(icon: "figure.stand.dress.line.vertical.figure", label: "Gender", value: patientdetail.gender)
                    sectionDivider
                    infoRow(icon: "drop.fill", label: "Blood Type", value: patientdetail.bloodType)
                    if patientdetail.name == "Grandma Marie" {
                        sectionDivider
                        infoRow(icon: "ruler", label: "Height", value: "160 cm")
                        sectionDivider
                        infoRow(icon: "scalemass", label: "Weight", value: "50 kg")
                    }
                }

                // Health Details
                infoSection(title: "Health Details") {
                    infoRow(icon: "exclamationmark.triangle.fill", label: "Allergies", value: patientdetail.allergies)
                    sectionDivider
                    infoRow(icon: "fork.knife", label: "Favorite Food", value: patientdetail.favoriteFood)
                    sectionDivider

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 10) {
                            Image(systemName: "doc.text.fill")
                                .font(.body)
                                .foregroundStyle(Color.accentColor)
                                .frame(width: 28)

                            Text("Health Profile")
                                .font(.body)
                                .foregroundStyle(AppTheme.primaryText)

                            Spacer()
                        }

                        if !patientdetail.healthNotes.isEmpty {
                            Text(patientdetail.healthNotes)
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondaryText)
                                .padding(.leading, 38)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                }

                Spacer(minLength: 40)
            }
        }
        .background(AppTheme.pageBackground)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingEditView) {
            PatientEditView(patient: $patientdetail)
        }
    }

    // MARK: - Section Builder
    private func infoSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.secondaryText)
                .padding(.horizontal)
                .padding(.bottom, 8)
                .padding(.top, 20)

            VStack(spacing: 0) {
                content()
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }

    // MARK: - Info Row
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.accentColor)
                .frame(width: 28)

            Text(label)
                .font(.body)
                .foregroundStyle(AppTheme.primaryText)

            Spacer()

            Text(value)
                .font(.body)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - Divider
    private var sectionDivider: some View {
        Divider()
            .overlay(AppTheme.divider)
            .padding(.leading, 52)
    }
}

#Preview {
    NavigationStack {
        PatientdetailView(patientdetail: SeedData.patient)
    }
}
