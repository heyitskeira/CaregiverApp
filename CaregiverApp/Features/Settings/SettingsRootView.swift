import SwiftUI

/// Temporary settings shell until the Settings feature owner integrates the full screen.
struct SettingsRootView: View {
    var body: some View {
        List {
            CareGroupSection()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}
