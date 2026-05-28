//
//  ContentView.swift
//  CaregiverApp
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("All Tasks", systemImage: "calendar") {
                NavigationStack {
                    ContentUnavailableView(
                        "All Tasks",
                        systemImage: "calendar",
                        description: Text("Task timeline will appear here.")
                    )
                    .navigationTitle("All Tasks")
                }
            }

            Tab("My Tasks", systemImage: "person.crop.circle.badge.checkmark") {
                NavigationStack {
                    ContentUnavailableView(
                        "My Tasks",
                        systemImage: "checkmark.circle",
                        description: Text("Your assigned tasks will appear here.")
                    )
                    .navigationTitle("My Tasks")
                }
            }

            Tab("Settings", systemImage: "gearshape") {
                NavigationStack {
                    SettingsRootView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.contactRepository, AppDependencies.live.contactRepository)
        .environment(\.taskRepository, AppDependencies.live.taskRepository)
        .environment(\.patientRepository, AppDependencies.live.patientRepository)
}
