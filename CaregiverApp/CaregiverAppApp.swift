//
//  CaregiverAppApp.swift
//  CaregiverApp
//

import Observation
import SwiftUI

@Observable
class AppRouter {
    var screen: AppScreen = .onboarding
}

enum AppTheme: String {
    case light
    case dark
    case auto
}

@main
struct CaregiverAppApp: App {
    @State private var router = AppRouter()
    @AppStorage("theme") private var theme = AppTheme.light.rawValue

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .preferredColorScheme(preferredColorScheme)
        }
    }

    private var preferredColorScheme: ColorScheme? {
        switch AppTheme(rawValue: theme) ?? .light {
        case .light:
            return .light
        case .dark:
            return .dark
        case .auto:
            return nil
        }
    }
}
