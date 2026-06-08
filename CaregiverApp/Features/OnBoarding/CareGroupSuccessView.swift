import SwiftUI

enum CareGroupSuccessType {
    case created
    case joined

    var title: String {
        switch self {
        case .created:
            return "Care Group Created!"
        case .joined:
            return "You've Joined!"
        }
    }

    var subtitle: String {
        switch self {
        case .created:
            return "You are all set. Start inviting family and friends to join"
        case .joined:
            return "Welcome to the care group.\nLet's get started"
        }
    }

    var showMembers: Bool {
        switch self {
        case .created:
            return false
        case .joined:
            return true
        }
    }
}

struct CareGroupSuccessView: View {
    let type: CareGroupSuccessType
    let groupName: String
    let members: [(name: String, image: String)]
    @Environment(AppRouter.self) private var router

    var body: some View {
        VStack {
            Image("Success")
            VStack(spacing: 12) {
                Text(type.title)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.accentColor)

                Text(type.subtitle)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 24)

            VStack(spacing: 24) {
                VStack(spacing: 24) {

                    HStack(alignment: .center, spacing: 24) {
                        GroupIcon()

                        VStack(alignment: .leading, spacing: 8) {
                            Text(groupName)
                                .font(.title3)
                                .bold()
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("\(members.count) members")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    if type.showMembers {
                        HStack(alignment: .top,spacing: 12) {
                            ForEach(0..<min(members.count, 4), id: \.self) { idx in
                                VStack {
                                    Circle()
                                        .fill(Color(.systemGray5))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 30))
                                        )

                                    Text(members[idx].name)
                                        .font(.caption)
                                }
                            }

                            if members.count > 4 {
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Text("+\(members.count - 4)")
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(
                    color: .accentColor.opacity(0.3),
                    radius: 4
                )

                Button {
                    // Navigate to home
                    router.screen = .home
                } label: {
                    Text("Go to home screen")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct GroupIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.13))
                .frame(width: 70, height: 70)

            Image(systemName: "person.3.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.green)
                .frame(width: 50, height: 50)
        }
    }
}

#Preview("Created") {
    CareGroupSuccessView(
        type: .created,
        groupName: "Grandma's Care Group",
        members: [
            (name: "You", image: "")
        ]
    )
}

#Preview("Joined") {
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
}
