import SwiftUI

struct SettingsRootView: View {
    enum Language: String, CaseIterable, Identifiable {
        case English, Indonesian, Dutch, Spanish
        var id: Self { self }
    }

    @State private var selectedLanguage: Language = .English

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
                    PatientdetailView(patientdetail: SeedData.patient)
                } label: {
                    Text("View Patient")
                }
            }

            Section(header: Text("Preferences")) {
                NavigationLink {
                    NotifsettingView()
                } label: {
                    PreferenceList(menuImage: "bell", menuName: "Notification Presferences")
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
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }

    private var profileHeader: some View {
        HStack(spacing: 16) {
            Image("profile1")
                .resizable()
                .scaledToFill()
                .frame(width: 88, height: 88)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 8) {
                Text("Sarah Sechan")
                    .font(.title3.weight(.semibold))

                Text("Primary Caregiver")
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.green.opacity(0.25)))

                Label("+628123456789", systemImage: "phone.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsRootView()
    }
    .environment(\.contactRepository, AppDependencies.live.contactRepository)
}
