//
//  SettingsRootView.swift
//  CaregiverApp
//
//  Profile settings page with care group, preferences, and account settings.
//

import SwiftUI

struct SettingsRootView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Profile Header
                    profileHeader
                        .padding(.bottom, 24)

                    // Care Group Section
                    settingsSection(title: "Care Group") {
                        NavigationLink(destination: CareGroupListView()) {
                            settingsRow(icon: "person.2.fill", label: "View Group")
                        }
                        sectionDivider
                        NavigationLink(destination:
                            PatientdetailView(patientdetail: SeedData.patient)
                        ) {
                            settingsRow(icon: "heart.text.clipboard", label: "View Patient")
                        }
                    }

                    // Preferences Section
                    settingsSection(title: "Preferences") {
                        NavigationLink(destination: NotifsettingView()) {
                            settingsRow(icon: "bell.fill", label: "Notification Preference")
                        }
                        sectionDivider
                        NavigationLink(destination: LangsettingView()) {
                            settingsRow(icon: "globe", label: "Language")
                        }
                        sectionDivider
                        NavigationLink(destination: PnSsetting()) {
                            settingsRow(icon: "lock.fill", label: "Privacy & Security")
                        }
                        sectionDivider
                        settingsRow(icon: "paintbrush.fill", label: "App Appearance")
                    }

                    // Account Settings Section
                    settingsSection(title: "Account Settings") {
                        settingsRow(icon: "pencil.line", label: "Edit Profile", showChevron: true)
                        sectionDivider
                        settingsRow(icon: "key.fill", label: "Change Password", showChevron: true)
                    }

                    // Sign Out
                    Button(action: {
                        // Sign out action
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.body)
                                .foregroundStyle(.red)
                                .frame(width: 32, height: 32)
                                .background(Color.red.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Text("Sign Out")
                                .font(.body)
                                .foregroundStyle(.red)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .padding(.top, 8)

                    Spacer(minLength: 40)
                }
            }
            .background(AppTheme.pageBackground)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        HStack(spacing: 14) {
            Image("profile1")
                .resizable()
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("Sarah Antoso")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.primaryText)

                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Text("Primary Caregiver")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(AppTheme.accentGreen)
                    .clipShape(Capsule())

                Text("+62 123-456-789")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Section Builder
    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.secondaryText)
                .padding(.horizontal)
                .padding(.bottom, 8)
                .padding(.top, 16)

            VStack(spacing: 0) {
                content()
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }

    // MARK: - Row
    private func settingsRow(icon: String, label: String, showChevron: Bool = true) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.accentColor)
                .frame(width: 32, height: 32)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(label)
                .font(.body)
                .foregroundStyle(AppTheme.primaryText)

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - Divider
    private var sectionDivider: some View {
        Divider()
            .overlay(AppTheme.divider)
            .padding(.leading, 58)
    }
}

#Preview {
    SettingsRootView()
        .environment(\.contactRepository, AppDependencies.live.contactRepository)
        .environment(\.patientRepository, AppDependencies.live.patientRepository)
}
