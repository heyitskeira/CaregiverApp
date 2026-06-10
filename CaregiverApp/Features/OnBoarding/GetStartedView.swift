import SwiftUI

struct GetStartedView: View {
    @Environment(AppRouter.self) private var router 

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Text("How would you like to get started")
                        .font(.largeTitle).bold()
                        .foregroundStyle(Color.accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("You can create or join a care group")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title3)
                }.padding(.vertical, 12)

                VStack(alignment: .center, spacing: 16) {
                    NavigationLink(destination: PatientInfoView().environment(router)) {
                        HStack(spacing: 20) {
                            ZStack {
                                Circle().fill(Color.blue.opacity(0.15)).frame(
                                    width: 80,
                                    height: 80
                                )
                                Image(systemName: "person.fill.badge.plus")
                                    .foregroundColor(.accent)
                                    .font(.largeTitle)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Create Care Group")
                                    .font(.title3)
                                    .bold()
                                    .foregroundStyle(Color.accentColor)

                                Text("I am the primary caregiver and want to create a new care group")
                                    .font(.subheadline)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.accent, lineWidth: 1)
                        )
                        .shadow(
                            color: .accentColor.opacity(0.3),
                            radius: 4,
                            x: 0,
                            y: 0
                        )
                    }

                    NavigationLink(destination: JoinCareGroupView().environment(router)) {
                        HStack(alignment: .center,spacing: 20) {
                            ZStack {
                                Circle().fill(Color.blue.opacity(0.15)).frame(
                                    width: 80,
                                    height: 80
                                )
                                Image(systemName: "person.2.fill")
                                    .foregroundColor(.accent)
                                    .font(.largeTitle)
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Join Care Group")
                                    .font(.title3)
                                    .bold()
                                    .foregroundStyle(Color.accentColor)

                                Text("I am a secondary caregiver and have an invite code to join an existing group")
                                    .font(.subheadline)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.accent, lineWidth: 1)
                        )
                        .shadow(
                            color: .accentColor.opacity(0.3),
                            radius: 4,
                            x: 0,
                            y: 0
                        )
                        
                    }
                }
                .foregroundStyle(.primary)
                .padding(.vertical, 60)
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    let router = AppRouter()

    GetStartedView()
        .environment(router)
}
