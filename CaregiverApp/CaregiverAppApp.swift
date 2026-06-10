import Observation
import SwiftUI

enum AppTheme: String {
    case light
    case dark
    case auto
}

@main
struct CaregiverAppApp: App {
    @State private var router = AppRouter()
    @State private var authService = SupabaseAuthService()

    @AppStorage("theme")
    private var theme = AppTheme.light.rawValue

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .environment(authService)
                .preferredColorScheme(preferredColorScheme)
                .task {
                    await initializeApp()
                }
        }
    }

    private func initializeApp() async {
        await authService.restoreSession()

        try? await Task.sleep(for: .seconds(2))

        if authService.isAuthenticated {
            router.screen = authService.currentMembership != nil
                ? .home
                : .getStarted
        } else {
            router.screen = .onboarding
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
