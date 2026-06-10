//
//  RootView.swift
//  CaregiverApp
//

import SwiftUI

enum AppScreen {
    case onboarding
    case signIn
    case signUp
    case getStarted
    case successCreate
    case successJoin
    case home
}

struct RootView: View {
    @Environment(AppRouter.self) private var router
    @Environment(SupabaseAuthService.self) private var authService

    var body: some View {
        switch router.screen {

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
                groupName: authService.currentMembership != nil ? "Your Care Team" : "Care Team",
                members: [(name: authService.currentUser?.name ?? "You", image: "")]
            )

        case .successJoin:
            CareGroupSuccessView(
                type: .joined,
                groupName: "Care Team",
                members: [(name: authService.currentUser?.name ?? "You", image: "")]
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
