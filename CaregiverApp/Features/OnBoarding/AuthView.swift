import SwiftUI

enum AuthMode {
    case signIn, signUp
}

struct AuthView: View {
    @State var authMode: AuthMode = .signIn
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        if (authMode == .signIn) {
            SignInview(authMode: $authMode)
                .environment(router)
        } else {
            SignUpView(authMode: $authMode)
                .environment(router)
        }
    }
}

#Preview {
    let router = AppRouter()
    return AuthView()
        .environment(router)
}
