import SwiftUI

struct CareGroupListView: View {
    @Environment(\.contactRepository) private var contactRepository
    @Environment(SessionStore.self) private var session

    @State private var store: CareGroupStore?
    @State private var searchText = ""
    @State private var isShowingSystemContactPicker = false
    @State private var importedDraft: CareContact?
    @State private var didStartLoad = false

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
                        NavigationLink(value: ContactEditorMode.edit(contact)) {
                            ContactRow(contact: contact)
                        }
                    }
                    .onDelete(perform: deleteContacts)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Care Group")
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
            careTeamID: session.currentCareTeam.id,
            isShowingSystemContactPicker: $isShowingSystemContactPicker,
            importedDraft: $importedDraft
        ) { contact in
            guard let store else { return }
            try await store.save(contact)
        }
        .navigationDestination(for: ContactEditorMode.self) { mode in
            ContactDetailView(careTeamID: session.currentCareTeam.id, mode: mode) { contact in
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
        Task { await newStore.load() }
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
