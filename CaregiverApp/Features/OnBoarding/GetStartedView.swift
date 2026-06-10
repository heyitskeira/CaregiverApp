import SwiftUI

struct GetStartedView: View {
    @State private var showCreate = false
    @State private var showJoin = false

    var body: some View {
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
                Button(action: {showCreate.toggle()}) {
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
                    .shadow(
                        color: .accentColor.opacity(0.3),
                        radius: 4,
                        x: 0,
                        y: 0
                    )
                }
                .fullScreenCover(isPresented: $showCreate) {
                    PatientInfoView()
                }
                
                Button(action: {showJoin.toggle()}) {
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
                    .shadow(
                        color: .accentColor.opacity(0.3),
                        radius: 4,
                        x: 0,
                        y: 0
                    )
                }
                .fullScreenCover(isPresented: $showJoin) {
                    JoinCareGroupView()
                }
            }
            .foregroundStyle(.primary)
            .padding(.vertical, 32)
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    GetStartedView()
}
