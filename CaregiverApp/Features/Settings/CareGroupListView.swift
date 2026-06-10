import SwiftUI

struct CareGroupListView: View {
    @Environment(\.contactRepository) private var contactRepository
    @State private var store: CareGroupStore?
    @State private var searchText = ""
    @State private var isShowingSystemContactPicker = false
    @State private var importedDraft: CareContact?
    @State private var didStartLoad = false

    @State private var selectedContact: CareContact?
    @State private var showRemoveSheet = false

    private var filteredContacts: [CareContact] {
        guard let store else { return [] }
        guard !searchText.isEmpty else { return store.contacts }
        return store.contacts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.relationship.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .center, spacing: 8) {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 94, height: 94)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 50))
                        )

                    Text("Grandma's Care Group").font(.title3)
                }.frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)

            Section {
                if store == nil {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                } else if filteredContacts.isEmpty {
                    emptyRow
                } else {
                    ForEach(filteredContacts) { contact in
                        //                        NavigationLink(value: ContactEditorMode.edit(contact)) {
                        //                            ContactRow(contact: contact)
                        //                        }
                        Button {
                            selectedContact = contact
                        } label: {
                            ContactRow(contact: contact)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteContacts)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search contacts")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingSystemContactPicker = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add care group member from Contacts")
            }
        }
        .careGroupAddMemberSheets(
            careTeamID: SeedData.careTeamID,
            isShowingSystemContactPicker: $isShowingSystemContactPicker,
            importedDraft: $importedDraft
        ) { contact in
            guard let store else { return }
            try await store.save(contact)
        }
        .navigationDestination(for: ContactEditorMode.self) { mode in
            ContactDetailView(careTeamID: SeedData.careTeamID, mode: mode) {
                contact in
                guard let store else { return }
                try await store.save(contact)
            }
        }
        .onAppear {
            startLoadingIfNeeded()
        }
        .refreshable {
            await store?.load()
        }
        .sheet(item: $selectedContact) { contact in
            NavigationStack {
                RemoveMemberSheet(
                    contact: contact,
                    onRemove: {
                        guard let store else { return }

                        Task {
                            await store.delete(id: contact.id)
                            selectedContact = nil
                        }
                    }
                )
            }
            .presentationDetents([.height(320)])
            .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var emptyRow: some View {
        ContentUnavailableView(
            searchText.isEmpty ? "No Care Group Members" : "No Results",
            systemImage: "person.2",
            description: Text(
                searchText.isEmpty
                    ? "Add family or friends from your Contacts app."
                    : "Try a different name or relationship."
            )
        )
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private func startLoadingIfNeeded() {
        guard !didStartLoad else { return }
        didStartLoad = true
        let newStore = CareGroupStore(contactRepository: contactRepository)
        store = newStore
        Task {
            await newStore.load()
        }
    }

    private func deleteContacts(at offsets: IndexSet) {
        guard let store else { return }
        let contacts = filteredContacts
        Task {
            for index in offsets {
                await store.delete(id: contacts[index].id)
            }
        }
    }
}

#Preview {
    CareGroupListView()
}
