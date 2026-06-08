import SwiftUI

struct ProfileRootView: View {
    enum Language: String, CaseIterable, Identifiable {
        case English, Indonesian, Dutch, Spanish
        var id: Self { self }
    }
    @AppStorage("theme") private var theme = AppTheme.light.rawValue
    @State private var selectedLanguage: Language = .English

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                VStack {
                    Text("Profile")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()

                    profileHeader

                    //                    CareGroupSection()
                    List {
                        Section("Care Group") {
                            NavigationLink {
                                CareGroupListView()
                            } label: {
                                Label("View Group", systemImage: "person.2")
                            }

                            NavigationLink {
                                PatientdetailView(
                                    patientdetail: SeedData.patient
                                )
                            } label: {
                                Label(
                                    "Patient Details",
                                    systemImage: "stethoscope"
                                )
                            }
                        }
                        
                        Section("Prefrences") {
                            Picker(selection: $theme) {
                                Text("Light").tag(AppTheme.light.rawValue)
                                Text("Dark").tag(AppTheme.dark.rawValue)
                                Text("System").tag(AppTheme.auto.rawValue)
                            } label: {
                                Label("App Appearance", systemImage: "sun.max")
                            }
                            .pickerStyle(.navigationLink)
                        }

                        Section("Account Settings") {
                            NavigationLink {
//                                CareGroupListView()
                            } label: {
                                Label("Profile", systemImage: "person")
                            }.disabled(true)

                            NavigationLink {
//                                PatientdetailView(
//                                    patientdetail: SeedData.patient
//                                )
                            } label: {
                                Label(
                                    "Sign Out",
                                    systemImage: "rectangle.portrait.and.arrow.right"
                                )
                                .foregroundStyle(Color.red)
                            }.disabled(true)
                        }

//                        Section(header: Text("Preferences")) {
//                            NavigationLink {
//                                NotifsettingView()
//                            } label: {
//                                PreferenceList(
//                                    menuImage: "bell",
//                                    menuName: "Notification Presferences"
//                                )
//                            }
//
//                            HStack {
//                                PreferenceList(
//                                    menuImage: "globe",
//                                    menuName: "Language"
//                                )
//                                Picker("", selection: $selectedLanguage) {
//                                    ForEach(Language.allCases) { language in
//                                        Text(language.rawValue).tag(language)
//                                    }
//                                }
//                            }
//
//                            NavigationLink {
//                                PnSsetting()
//                            } label: {
//                                PreferenceList(
//                                    menuImage: "lock",
//                                    menuName: "Privacy & Security"
//                                )
//                            }
//                        }
                    }
                    Spacer()

                }
                .background(Color.clear)
            }
        }
    }

    private var profileHeader: some View {
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
                Text("Sarah Antoso")
                    .font(.title3.weight(.bold))

                Text("Primary Caregiver")
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
    ProfileRootView()
        .environment(
            \.contactRepository,
            AppDependencies.live.contactRepository
        )
}
