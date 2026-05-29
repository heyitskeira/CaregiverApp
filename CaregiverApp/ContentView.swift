//
//  ContentView.swift
//  CaregiverApp
//

import SwiftUI

enum AppTab: String, CaseIterable {
    case timeline
    case details
    case settings
    case addTask

    var title: String {
        switch self {
        case .timeline:
            return "Timeline"
        case .details:
            return "Details"
        case .settings:
            return "Settings"
        case .addTask:
            return "Add Task"
        }
    }

    var icon: String {
        switch self {
        case .timeline:
            return "list.bullet.rectangle.portrait"
        case .details:
            return "stethoscope"
        case .settings:
            return "gearshape"
        case .addTask:
            return "plus"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .timeline
    @State private var showTaskSheet = false

    var body: some View {
        
        TabView(selection: $selectedTab) {
            Tab (
                AppTab.timeline.title,
                systemImage: AppTab.timeline.icon,
                value: AppTab.timeline
            ) {
                NavigationStack {
                    TimelineView()
                }
            }
            
            Tab(
                AppTab.details.title,
                systemImage: AppTab.details.icon,
                value: .details
            ) {
                NavigationStack {
                    ContentUnavailableView(
                        "Details",
                        systemImage: "stethoscope",
                        description: Text("Details will appear here.")
                    )
                    .navigationTitle("Details")
                }
            }
            
            Tab(
                AppTab.settings.title,
                systemImage: AppTab.settings.icon,
                value: .settings
            ) {
                SettingsRootView()
            }
            
            Tab(
                AppTab.addTask.title,
                systemImage: AppTab.addTask.icon,
                value: .addTask,
                role: .search
            ) {}
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .addTask {
                selectedTab = oldValue
                showTaskSheet = true
            }
        }
        .sheet(isPresented: $showTaskSheet) {
            TaskSheetView()
        }

    }
}

#Preview {
    ContentView()
        .environment(\.contactRepository, AppDependencies.live.contactRepository)
        .environment(\.taskRepository, AppDependencies.live.taskRepository)
        .environment(\.patientRepository, AppDependencies.live.patientRepository)
}
