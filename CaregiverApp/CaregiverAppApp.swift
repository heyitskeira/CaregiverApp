//
//  CaregiverAppApp.swift
//  CaregiverApp
//

import SwiftUI

@main
struct CaregiverAppApp: App {
    private let dependencies = AppDependencies.live
    @State private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if session.isSignedIn {
                    ContentView()
                        .environment(\.contactRepository, dependencies.contactRepository)
                        .environment(\.taskRepository, dependencies.taskRepository)
                        .environment(\.patientRepository, dependencies.patientRepository)
                        .environment(\.logRepository, dependencies.logRepository)
                        .environment(\.taskRequestRepository, dependencies.taskRequestRepository)
                } else {
                    OnboardingMainView()
                }
            }
            .environment(session)
        }
    }
}
