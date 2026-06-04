import SwiftUI

/// Details tab: health profile for the person receiving care (e.g. Grandma Marie).
struct PatientDetailsTabView: View {
    @Environment(\.patientRepository) private var patientRepository
    @State private var patient: CareRecipient?
    @State private var isLoading = true
    @State private var didLoad = false

    var body: some View {
        Group {
            if isLoading && patient == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let patient {
                patientList(patient)
            } else {
                ContentUnavailableView(
                    "No Patient Profile",
                    systemImage: "stethoscope",
                    description: Text("Patient details will appear here once configured.")
                )
            }
        }
        .background(Color(.systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            loadPatientIfNeeded()
        }
        .refreshable {
            await reloadPatient()
        }
    }

    private func patientList(_ patient: CareRecipient) -> some View {
        List {
            Section {
                detailsHeader(patient)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section {
                patientSummaryCard(patient)
            }
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section("Basic Information") {
                PatientDetailRow(
                    icon: "calendar",
                    title: "Date of Birth",
                    value: patient.dateOfBirthString
                )
                PatientDetailRow(
                    icon: "figure.stand",
                    title: "Gender",
                    value: patient.gender
                )
                PatientDetailRow(
                    icon: "drop.fill",
                    title: "Blood Type",
                    value: patient.bloodType
                )
            }

            Section("Health Information") {
                PatientDetailRow(
                    icon: "bandage.fill",
                    title: "Allergies",
                    value: patient.allergies.isEmpty ? "None listed" : patient.allergies
                )
                PatientDetailRow(
                    icon: "fork.knife",
                    title: "Favorite Food",
                    value: patient.favoriteFood.isEmpty ? "—" : patient.favoriteFood
                )
                VStack(alignment: .leading, spacing: 8) {
                    PatientDetailRow(
                        icon: "doc.text.fill",
                        title: "Health Profile",
                        value: ""
                    )
                    Text(patient.healthNotes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 44)
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.insetGrouped)
    }

    private func detailsHeader(_ patient: CareRecipient) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Details")
                    .font(.title2)
                    .fontWeight(.bold)
                Text(patient.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "stethoscope")
                .font(.title2)
                .foregroundStyle(.black)
                .padding(12)
                .background(Color.gray.opacity(0.15))
                .clipShape(Circle())
        }
        .padding(.top, 8)
    }

    private func patientSummaryCard(_ patient: CareRecipient) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 72, height: 72)
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(patient.name)
                    .font(.title3.weight(.semibold))
                Text("\(patient.ageInYears) years old")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Care recipient")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color(red: 0.2, green: 0.4, blue: 0.8))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.12))
                    )
            }

            Spacer(minLength: 0)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func loadPatientIfNeeded() {
        guard !didLoad else { return }
        didLoad = true
        Task {
            await reloadPatient()
        }
    }

    private func reloadPatient() async {
        if patient == nil {
            isLoading = true
        }
        defer { isLoading = false }
        patient = try? await patientRepository.fetchPatient()
    }
}

private struct PatientDetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color(red: 0.2, green: 0.4, blue: 0.8))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.12))
                )

            Text(title)
                .font(.subheadline)

            Spacer(minLength: 8)

            if !value.isEmpty {
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        PatientDetailsTabView()
    }
    .environment(\.patientRepository, AppDependencies.live.patientRepository)
}
