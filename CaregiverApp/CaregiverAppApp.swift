//
//  CaregiverAppApp.swift
//  CaregiverApp
//

import SwiftUI
import Observation

@Observable
class AppRouter {
    var screen: AppScreen = .onboarding
}

@main
struct CaregiverAppApp: App {
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
        }
    }
}
