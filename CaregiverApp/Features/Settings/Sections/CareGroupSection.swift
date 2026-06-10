import SwiftUI

struct CareGroupSection: View {
    @Environment(\.contactRepository) private var contactRepository
    @Environment(SessionStore.self) private var session

    @State private var store: CareGroupStore?
    @State private var previewContacts: [CareContact] = []
    @State private var isShowingSystemContactPicker = false
    @State private var importedDraft: CareContact?

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Members").font(.headline)
                    Spacer()
                    NavigationLink {
                        CareGroupListView()
                    } label: {
                        Text("View All").font(.subheadline).foregroundStyle(.green)
                    }
                }

                if previewContacts.isEmpty {
                    Text("Add family or friends to share caregiving tasks.")
                        .font(.subheadline).foregroundStyle(.secondary)
                } else {
                    CareGroupPreviewStrip(
                        contacts: previewContacts,
                        onAddMember: { isShowingSystemContactPicker = true }
                    )
                }

                if previewContacts.isEmpty {
                    Button {
                        isShowingSystemContactPicker = true
                    } label: {
                        Label("Add from Contacts", systemImage: "person.crop.circle.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent).controlSize(.small)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Care Group")
        }
        .onAppear {
            if store == nil {
                store = CareGroupStore(contactRepository: contactRepository)
                Task { await reloadPreview() }
            }
        }
        .careGroupAddMemberSheets(
            careTeamID: session.currentCareTeam.id,
            isShowingSystemContactPicker: $isShowingSystemContactPicker,
            importedDraft: $importedDraft
        ) { contact in
            try await store?.save(contact)
            await reloadPreview()
        }
    }

    private func reloadPreview() async {
        await store?.load()
        previewContacts = store?.contacts.prefix(3).map { $0 } ?? []
    }
}

struct CareGroupPreviewStrip: View {
    let contacts: [CareContact]
    var onAddMember: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(contacts) { contact in
                    VStack(spacing: 8) {
                        ContactAvatarView(contact: contact, size: 56)
                        Text(contact.name).font(.caption.weight(.semibold)).lineLimit(1)
                        Text(contact.relationship).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                    }
                    .frame(width: 72)
                }

                Button(action: onAddMember) {
                    VStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                                .foregroundStyle(.tertiary)
                            Image(systemName: "plus").font(.title3.weight(.semibold)).foregroundStyle(.secondary)
                        }
                        .frame(width: 56, height: 56)
                        Text("Add Member").font(.caption2).foregroundStyle(.secondary).lineLimit(2).multilineTextAlignment(.center)
                    }
                    .frame(width: 72)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add care group member from Contacts")
            }
            .padding(.vertical, 4)
        }
    }
}
