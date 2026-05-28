import SwiftUI

struct CareGroupSection: View {
    @Environment(\.contactRepository) private var contactRepository
    @State private var previewContacts: [CareContact] = []

    var body: some View {
        Section {
            NavigationLink {
                CareGroupListView()
            } label: {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Members")
                            .font(.headline)
                        Spacer()
                        Text("View All")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    }

                    if previewContacts.isEmpty {
                        Text("Add family or friends to share caregiving tasks.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        CareGroupPreviewStrip(contacts: previewContacts)
                    }
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("Care Group")
        }
        .task {
            previewContacts = (try? await contactRepository.fetchContacts())?
                .prefix(3)
                .map { $0 } ?? []
        }
    }
}

struct CareGroupPreviewStrip: View {
    let contacts: [CareContact]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(contacts) { contact in
                    VStack(spacing: 8) {
                        ContactAvatarView(contact: contact, size: 56)
                        Text(contact.name)
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                        Text(contact.relationship)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .frame(width: 72)
                }

                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .foregroundStyle(.tertiary)
                        Image(systemName: "plus")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 56, height: 56)
                    Text("Add Member")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 72)
                .accessibilityHidden(true)
            }
            .padding(.vertical, 4)
        }
    }
}
