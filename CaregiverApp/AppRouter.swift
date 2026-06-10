//
//  AppRouter.swift
//  JagaKin
//
//  Created by Dzikry Aji Santoso on 10/06/26.
//

import Observation

@Observable
class AppRouter {
    var screen: AppScreen = .splash
}

enum AppScreen {
    case splash
    case onboarding
    case signIn
    case signUp
    case getStarted
    case successCreate
    case successJoin
    case home
}

