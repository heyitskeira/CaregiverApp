//
//  ContentView.swift
//  CaregiverApp
//

import SwiftUI

enum AppTab: String, CaseIterable {
    case allTasks
    case myTasks
    case settings

    var title: String {
        switch self {
        case .allTasks:
            return "All Tasks"
        case .myTasks:
            return "My Tasks"
        case .settings:
            return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .allTasks:
            return "calendar"
        case .myTasks:
            return "person.crop.circle.badge.checkmark"
        case .settings:
            return "gearshape"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .allTasks

    var body: some View {
        TabView(selection: $selectedTab) {

            Tab(
                AppTab.allTasks.title,
                systemImage: AppTab.allTasks.icon,
                value: AppTab.allTasks
            ) {
                NavigationStack {
                    ContentUnavailableView(
                        "All Tasks",
                        systemImage: "calendar",
                        description: Text("Task timeline will appear here.")
                    )
                    .navigationTitle("All Tasks")
                }
            }

            Tab(
                AppTab.myTasks.title,
                systemImage: AppTab.myTasks.icon,
                value: AppTab.myTasks
            ) {
                NavigationStack {
                    ContentUnavailableView(
                        "My Tasks",
                        systemImage: "checkmark.circle",
                        description: Text("Your assigned tasks will appear here.")
                    )
                    .navigationTitle("My Tasks")
                }
            }

            Tab(
                AppTab.settings.title,
                systemImage: AppTab.settings.icon,
                value: AppTab.settings
            ) {
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
