import Contacts
import SwiftUI

struct CareGroupListView: View {
    @Environment(\.contactRepository) private var contactRepository
    @State private var store: CareGroupStore?
    @State private var searchText = ""
    @State private var isShowingSystemContactPicker = false
    @State private var importedDraft: CareContact?

    private var filteredContacts: [CareContact] {
        guard let store else { return [] }
        guard !searchText.isEmpty else { return store.contacts }
        return store.contacts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.relationship.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if let store {
                listContent(store: store)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Care Group")
        .navigationBarTitleDisplayMode(.large)
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
        .sheet(isPresented: $isShowingSystemContactPicker) {
            SystemContactPicker(
                onSelect: { cnContact in
                    isShowingSystemContactPicker = false
                    importedDraft = cnContact.toCareContact()
                },
                onCancel: {
                    isShowingSystemContactPicker = false
                }
            )
            .ignoresSafeArea()
        }
        .sheet(item: $importedDraft) { draft in
            NavigationStack {
                ContactDetailView(mode: .imported(draft)) { contact in
                    guard let store else { return }
                    try await store.save(contact)
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            importedDraft = nil
                        }
                    }
                }
            }
        }
        .navigationDestination(for: ContactEditorMode.self) { mode in
            ContactDetailView(mode: mode) { contact in
                guard let store else { return }
                try await store.save(contact)
            }
        }
        .task {
            if store == nil {
                store = CareGroupStore(contactRepository: contactRepository)
            }
            await store?.load()
        }
        .refreshable {
            await store?.load()
        }
    }

    @ViewBuilder
    private func listContent(store: CareGroupStore) -> some View {
        if store.isLoading && store.contacts.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if filteredContacts.isEmpty {
            ContentUnavailableView(
                searchText.isEmpty ? "No Care Group Members" : "No Results",
                systemImage: "person.2",
                description: Text(
                    searchText.isEmpty
                        ? "Add family or friends from your Contacts app."
                        : "Try a different name or relationship."
                )
            )
            .overlay(alignment: .bottom) {
                if searchText.isEmpty {
                    Button("Add from Contacts") {
                        isShowingSystemContactPicker = true
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, 24)
                }
            }
        } else {
            List {
                ForEach(filteredContacts) { contact in
                    NavigationLink(value: ContactEditorMode.edit(contact)) {
                        ContactRow(contact: contact, showsChevron: true)
                    }
                }
                .onDelete { indexSet in
                    Task {
                        for index in indexSet {
                            await store.delete(id: filteredContacts[index].id)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }

        if let errorMessage = store.errorMessage {
            Text(errorMessage)
                .font(.footnote)
                .foregroundStyle(.red)
                .padding()
        }
    }
}
