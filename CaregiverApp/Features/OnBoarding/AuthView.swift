import SwiftUI

enum AuthMode {
    case signIn, signUp
}

struct AuthView: View {
    var initialMode: AuthMode = .signIn
    @State private var authMode: AuthMode
    @State private var showGetStarted = false

    init(initialMode: AuthMode = .signIn) {
        self.initialMode = initialMode
        _authMode = State(initialValue: initialMode)
    }

    var body: some View {
        Group {
            if authMode == .signIn {
                SignInview(authMode: $authMode, onSuccess: { showGetStarted = true })
            } else {
                SignUpView(authMode: $authMode, onSuccess: { showGetStarted = true })
            }
        }
        .fullScreenCover(isPresented: $showGetStarted) {
            GetStartedView()
        }
    }
}

#Preview {
    AuthView()
        .environment(SessionStore())
}
