//
//  RootView.swift
//  CaregiverApp
//
//  Created by Dzikry Aji Santoso on 05/06/26.
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
    private let dependencies = AppDependencies.live

    var body: some View {
        switch router.screen {

        case .onboarding:
            OnboardingMainView()
                .environment(router)

        case .signIn:
            AuthView(authMode: .signIn)
                .environment(router)
            
        case .signUp:
            AuthView(authMode: .signUp)
                .environment(router)

        case .getStarted:
            GetStartedView()
                .environment(router)
            
        case .successCreate:
            CareGroupSuccessView(
                type: .created,
                groupName: "Grandma's Care Group",
                members: [
                    (name: "You", image: "")
                ]
            )
            .environment(router)
            
        case .successJoin:
            CareGroupSuccessView(
                type: .joined,
                groupName: "Grandma's Care Group",
                members: [
                    (name: "Sarah", image: ""),
                    (name: "Lily", image: ""),
                    (name: "James", image: ""),
                    (name: "John", image: ""),
                    (name: "Mike", image: "")
                ]
            )
            .environment(router)

        case .home:
            ContentView()
                .environment(\.contactRepository, dependencies.contactRepository)
                .environment(\.taskRepository, dependencies.taskRepository)
                .environment(\.patientRepository, dependencies.patientRepository)

        }
    }
}

#Preview {
    let router = AppRouter()
    router.screen = .onboarding

    return RootView()
        .environment(router)
}
