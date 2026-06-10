import SwiftUI

struct SettingsRootView: View {
    @Environment(SessionStore.self) private var session
    @Environment(\.patientRepository) private var patientRepository

    enum Language: String, CaseIterable, Identifiable {
        case English, Indonesian, Dutch, Spanish
        var id: Self { self }
    }

    @State private var selectedLanguage: Language = .English
    @State private var patient: CareRecipient? = nil

    var body: some View {
        List {
            Section {
                profileHeader
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

            CareGroupSection()

            Section {
                NavigationLink {
                    if let p = patient {
                        PatientdetailView(patientdetail: p)
                    } else {
                        PatientdetailView(patientdetail: SeedData.patient)
                    }
                } label: {
                    Text("View Patient")
                }
            }

            Section(header: Text("Preferences")) {
                NavigationLink {
                    NotifsettingView()
                } label: {
                    PreferenceList(menuImage: "bell", menuName: "Notification Preferences")
                }

                HStack {
                    PreferenceList(menuImage: "globe", menuName: "Language")
                    Picker("", selection: $selectedLanguage) {
                        ForEach(Language.allCases) { language in
                            Text(language.rawValue).tag(language)
                        }
                    }
                }

                NavigationLink {
                    PnSsetting()
                } label: {
                    PreferenceList(menuImage: "lock", menuName: "Privacy & Security")
                }
            }

            Section {
                Button(role: .destructive) {
                    session.signOut()
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .task {
            patient = try? await patientRepository.fetchPatient()
        }
    }

    private var profileHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(Color.accentColor.opacity(0.15)).frame(width: 88, height: 88)
                Text(initials(for: session.currentUser.name))
                    .font(.title2.bold())
                    .foregroundStyle(Color.accentColor)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(session.currentUser.name)
                    .font(.title3.weight(.semibold))

                Text(session.currentUser.role == .primaryCaregiver ? "Primary Caregiver" : "Helper")
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(Color.green.opacity(0.25)))

                if !session.currentUser.phone.isEmpty {
                    Label(session.currentUser.phone, systemImage: "phone.fill")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first.map { String($0) } }
        return letters.joined()
    }
}

#Preview {
    NavigationStack {
        SettingsRootView()
    }
    .environment(SessionStore())
    .environment(\.contactRepository, AppDependencies.live.contactRepository)
    .environment(\.patientRepository, AppDependencies.live.patientRepository)
}
