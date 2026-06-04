import SwiftUI

enum AuthMode {
    case signIn, signUp
}

struct AuthView: View {
    @State private var authMode: AuthMode = .signIn
    
    var body: some View {
        if (authMode == .signIn) {
            SignInview(authMode: $authMode)
        } else {
            SignUpView(authMode: $authMode)
        }
    }
}

#Preview {
    AuthView()
}
