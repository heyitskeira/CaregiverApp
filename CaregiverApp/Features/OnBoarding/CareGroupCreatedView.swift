import SwiftUI

struct CareGroupCreatedView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        VStack {
            Image("Success")
            VStack(spacing: 12) {
                Text("Care Group Created!")
                    .font(.largeTitle).bold().foregroundColor(.accentColor)
                Text("You are all set. Start inviting family and\nfriends to join")
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 24)

            VStack(spacing: 24) {
                HStack(alignment: .center, spacing: 24) {
                    GroupIcon()
                    VStack(alignment: .leading, spacing: 8) {
                        Text(session.currentCareTeam.name)
                            .font(.title3).bold()
                            .foregroundColor(.accentColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("1 member")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding().frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(color: .accentColor.opacity(0.3), radius: 4, x: 0, y: 0)

                Button {
                    session.finishOnboarding()
                } label: {
                    Text("Go to home screen")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity).padding()
                        .background(Color.accentColor).foregroundColor(.white).clipShape(Capsule())
                }
            }
        }
        .padding()
    }
}

#Preview {
    CareGroupCreatedView().environment(SessionStore())
}
