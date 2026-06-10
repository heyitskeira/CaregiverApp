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
    @State private var showSplash = true
    @State private var router = AppRouter()
    @State private var authService = SupabaseAuthService()

    @AppStorage("theme")
    private var theme = AppTheme.light.rawValue

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .environment(router)
                    .environment(authService)

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
            .preferredColorScheme(preferredColorScheme)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
            .task { await syncAuthState() }
        }
    }

    /// Keep router in sync with Supabase session state.
    private func syncAuthState() async {
        if authService.isAuthenticated && authService.currentMembership != nil {
            router.screen = .home
        }
    }

    private var preferredColorScheme: ColorScheme? {
        switch AppTheme(rawValue: theme) ?? .light {
        case .light: return .light
        case .dark: return .dark
        case .auto: return nil
        }
    }
}
