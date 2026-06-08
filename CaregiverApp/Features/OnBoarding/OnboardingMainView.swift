import SwiftUI


struct OnboardingMainView: View {
    @Environment(AppRouter.self) private var router
    @State private var onboardingFinished = false

    var body: some View {
        if onboardingFinished {
            WelcomeScreenView()
                .environment(router)
        } else {
            OnboardingView(onboardingFinished: $onboardingFinished)
        }
    }
}

#Preview {
    OnboardingMainView()
}
