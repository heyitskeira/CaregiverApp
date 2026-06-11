import SwiftUI

struct ProfileRootView: View {
    enum Language: String, CaseIterable, Identifiable {
        case English, Indonesian, Dutch, Spanish
        var id: Self { self }
    }
    @AppStorage("theme") private var theme = AppTheme.light.rawValue
    @State private var selectedLanguage: Language = .English
    @Environment(\.authService) private var authService
    @Environment(AppRouter.self) private var router
    @State private var isSigningOut = false
    @State private var signOutError: String?

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

                    ProfileHeader(
                        title: "Sarah Antoso",
                        subTitle: "Primary Caregiver"
                    )

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
                            } label: {
                                Label("Profile", systemImage: "person")
                            }.disabled(true)

                            Button {
                                isSigningOut = true
                                Task {
                                    do {
                                        try await authService.signOut()
                                        router.screen = .onboarding
                                    } catch {
                                        signOutError = error.localizedDescription
                                    }
                                    isSigningOut = false
                                }
                            } label: {
                                Label(
                                    isSigningOut ? "Signing Out…" : "Sign Out",
                                    systemImage: "rectangle.portrait.and.arrow.right"
                                )
                                .foregroundStyle(Color.red)
                            }
                            .disabled(isSigningOut)
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
}

#Preview {
    ProfileRootView()
        .environment(\.authService, AppDependencies.live.authService)
        .environment(AppRouter())
        .environment(
            \.contactRepository,
            AppDependencies.live.contactRepository
        )
}
