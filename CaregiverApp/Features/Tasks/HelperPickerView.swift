//
//  HelperPickerView.swift
//  CaregiverApp
//

import SwiftUI

struct HelperPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.contactRepository) private var contactRepository

    var excludedContactIDs: Set<UUID> = []
    let onSelect: (CareContact) -> Void

    @State private var contacts: [CareContact] = []
    @State private var isLoading = true
    @State private var searchText = ""

    private var selectableContacts: [CareContact] {
        contacts.filter { !excludedContactIDs.contains($0.id) }
    }

    private var filteredContacts: [CareContact] {
        guard !searchText.isEmpty else { return selectableContacts }
        return selectableContacts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.relationship.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredContacts.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "No Helpers Available" : "No Results",
                        systemImage: "person.2",
                        description: Text(
                            searchText.isEmpty
                                ? excludedContactIDs.isEmpty
                                    ? "Add care group members in Settings to assign tasks."
                                    : "All care group members are already assigned."
                                : "Try a different name or relationship."
                        )
                    )
                } else {
                    List(filteredContacts) { contact in
                        Button {
                            onSelect(contact)
                            dismiss()
                        } label: {
                            ContactRow(contact: contact)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Select Helper")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search care group")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadContacts()
            }
        }
    }

    private func loadContacts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            contacts = try await contactRepository.fetchContacts()
        } catch {
            contacts = []
        }
    }
}

#Preview {
    HelperPickerView { _ in }
        .environment(\.contactRepository, AppDependencies.live.contactRepository)
}
