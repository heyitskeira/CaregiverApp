import SwiftUI

struct CareGroupJoinedView: View {
    @Environment(SessionStore.self) private var session

    let members = [
        (name: "Sarah", image: "person1"),
        (name: "Lily", image: "person2"),
        (name: "James", image: "person3"),
        (name: "Sarah", image: "person4"),
        (name: "John", image: "person5"),
        (name: "John", image: "person5")
    ]

    var body: some View {
        VStack {
            Image("Success")
            VStack(spacing: 12) {
                Text("You've Joined!")
                    .font(.largeTitle).bold().foregroundColor(.accentColor)
                Text("Welcome to the care group.\nLet's get started")
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 24)

            VStack(spacing: 24) {
                VStack(spacing: 24) {
                    HStack(alignment: .center, spacing: 24) {
                        GroupIcon()
                        VStack(alignment: .leading, spacing: 8) {
                            Text(session.currentCareTeam.name)
                                .font(.title3).bold()
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(members.count) members")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    HStack(spacing: 12) {
                        ForEach(0..<min(members.count, 4), id: \.self) { idx in
                            VStack {
                                Circle()
                                    .fill(Color(.systemGray5)).frame(width: 60, height: 60)
                                    .overlay(Image(systemName: "person.fill").foregroundColor(.gray).font(.system(size: 30)))
                                Text(members[idx].name).font(.caption).foregroundColor(.primary)
                            }
                            .frame(maxHeight: .infinity, alignment: .top)
                        }
                        if members.count > 4 {
                            VStack {
                                Circle()
                                    .fill(Color.accent).frame(width: 60, height: 60)
                                    .overlay(Text("+\(members.count - 4)").foregroundColor(.white))
                            }
                            .frame(maxHeight: .infinity, alignment: .top)
                        }
                    }
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

struct GroupIcon: View {
    var body: some View {
        ZStack {
            Circle().fill(Color.green.opacity(0.13)).frame(width: 70, height: 70)
            Image(systemName: "person.3.fill")
                .resizable().scaledToFit()
                .foregroundColor(.green).frame(width: 50, height: 50)
        }
    }
}

#Preview {
    CareGroupJoinedView().environment(SessionStore())
}
