import SwiftUI


struct OnboardingMainView: View {
    @State private var onboardingFinished = false

    var body: some View {
        if onboardingFinished {
            WelcomeScreenView()
        } else {
            OnboardingView(onboardingFinished: $onboardingFinished)
        }
    }
}

#Preview {
    OnboardingMainView()
}
