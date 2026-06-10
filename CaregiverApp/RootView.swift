//
//  RootView.swift
//  CaregiverApp
//

import SwiftUI

struct RootView: View {
    @Environment(AppRouter.self) private var router
    @Environment(SupabaseAuthService.self) private var authService

    var body: some View {
        switch router.screen {

        case .splash:
            SplashView()

        case .onboarding:
            OnboardingMainView()

        case .signIn:
            AuthView(authMode: .signIn)

        case .signUp:
            AuthView(authMode: .signUp)

        case .getStarted:
            GetStartedView()

        case .successCreate:
            CareGroupSuccessView(
                type: .created,
                groupName: "Your Care Team",
                members: [
                    (
                        name: authService.currentUser?.name ?? "You",
                        image: ""
                    )
                ]
            )

        case .successJoin:
            CareGroupSuccessView(
                type: .joined,
                groupName: "Care Team",
                members: [
                    (
                        name: authService.currentUser?.name ?? "You",
                        image: ""
                    )
                ]
            )

        case .home:
            let deps = AppDependencies.supabase(authService: authService)

            ContentView()
                .environment(\.contactRepository, deps.contactRepository)
                .environment(\.taskRepository, deps.taskRepository)
                .environment(\.patientRepository, deps.patientRepository)
                .environment(\.authService, deps.authService)
                .environment(\.logRepository, deps.logRepository)
        }
    }
}

#Preview {
    let router = AppRouter()
    let auth = MockAuthService()
    router.screen = .onboarding
    return RootView()
        .environment(router)
        .environment(SupabaseAuthService())
}
