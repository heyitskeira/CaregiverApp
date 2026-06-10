//
//  PnSsetting.swift
//  CaregiverApp
//

import SwiftUI

struct PnSsetting: View {
    @State private var biometricLock = false
    @State private var twoFactorEnabled = false
    @State private var shareActivityStatus = true
    @State private var allowDataCollection = false

    var body: some View {
        List {
            Section(header: Text("Security")) {
                VStack(alignment: .leading) {
                    Toggle("Face ID / Touch ID", isOn: $biometricLock)
                    Text("Require biometric authentication to open the app")
                        .font(.caption).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading) {
                    Toggle("Two-Factor Authentication", isOn: $twoFactorEnabled)
                    Text("Add an extra layer of security when signing in")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }

            Section(header: Text("Privacy")) {
                VStack(alignment: .leading) {
                    Toggle("Share Activity Status", isOn: $shareActivityStatus)
                    Text("Let care group members see when you were last active")
                        .font(.caption).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading) {
                    Toggle("Allow Anonymous Analytics", isOn: $allowDataCollection)
                    Text("Help improve the app by sharing anonymous usage data")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }

            Section(header: Text("Account")) {
                NavigationLink {
                    Text("Data export functionality coming soon.")
                        .padding()
                } label: {
                    Label("Export My Data", systemImage: "square.and.arrow.up")
                }

                Button(role: .destructive) {
                    // Delete account flow
                } label: {
                    Label("Delete Account", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Privacy & Security")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        PnSsetting()
    }
}
