//
//  CaregiverAppApp.swift
//  CaregiverApp
//

import SwiftUI

@main
struct CaregiverAppApp: App {
    private let dependencies = AppDependencies.live

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.contactRepository, dependencies.contactRepository)
                .environment(\.taskRepository, dependencies.taskRepository)
                .environment(\.patientRepository, dependencies.patientRepository)
        }
    }
}
