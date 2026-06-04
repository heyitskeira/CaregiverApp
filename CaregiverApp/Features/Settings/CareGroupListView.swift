//
//  CareGroupListView.swift
//  CaregiverApp
//
//  Care group view showing group name, member list, and member detail sheet.
//

import Contacts
import SwiftUI

struct CareGroupListView: View {
    @Environment(\.contactRepository) private var contactRepository
    @State private var store: CareGroupStore?
    @State private var isShowingSystemContactPicker = false
    @State private var importedDraft: CareContact?
    @State private var selectedMember: CareContact?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Group header with photo and name
                groupHeader
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                // Members list
                if let store {
                    if store.isLoading && store.contacts.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if store.contacts.isEmpty {
                        emptyState
                    } else {
                        membersSection(contacts: store.contacts)
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                }

                if let errorMessage = store?.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding()
                }

                Spacer(minLength: 40)
            }
        }
        .background(AppTheme.pageBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        // Share / invite
                    } label: {
                        Image(systemName: "envelope.fill")
                            .font(.body)
                            .foregroundStyle(AppTheme.primaryText)
                            .frame(width: 36, height: 36)
                            .background(AppTheme.trayIconBackground)
                            .clipShape(Circle())
                    }

                    Button {
                        isShowingSystemContactPicker = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.primaryText)
                            .frame(width: 36, height: 36)
                            .background(AppTheme.trayIconBackground)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Add care group member from Contacts")
                }
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
        .sheet(item: $selectedMember) { member in
            MemberDetailSheet(
                member: member,
                onRemove: {
                    Task {
                        await store?.delete(id: member.id)
                        selectedMember = nil
                    }
                }
            )
            .presentationDetents([.height(300)])
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

    // MARK: - Group Header
    private var groupHeader: some View {
        VStack(spacing: 12) {
            Image("profile1")
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)

            Text("Grandma Marie's Care Group")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.primaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.secondaryText.opacity(0.5))

            Text("No Members Yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.secondaryText)

            Text("Add family or friends from your Contacts app.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText.opacity(0.7))

            Button("Add from Contacts") {
                isShowingSystemContactPicker = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 40)
    }

    // MARK: - Members Section
    private func membersSection(contacts: [CareContact]) -> some View {
        VStack(spacing: 0) {
            // Column headers
            HStack {
                Text("A")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(width: 44)

                Spacer()

                // We could add column headers here if needed
            }
            .padding(.horizontal)
            .padding(.bottom, 4)

            VStack(spacing: 0) {
                ForEach(contacts) { contact in
                    Button {
                        selectedMember = contact
                    } label: {
                        memberRow(contact: contact)
                    }
                    .buttonStyle(.plain)

                    if contact.id != contacts.last?.id {
                        Divider()
                            .overlay(AppTheme.divider)
                            .padding(.leading, 58)
                    }
                }
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }

    // MARK: - Member Row
    private func memberRow(contact: CareContact) -> some View {
        HStack(spacing: 12) {
            // Avatar
            Text(contact.initials)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(AppTheme.assignedNode)
                .clipShape(Circle())

            // Name
            Text(contact.name)
                .font(.body)
                .foregroundStyle(AppTheme.primaryText)

            Spacer()

            // Additional info (date/relationship)
            Text(contact.relationship)
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

// MARK: - Member Detail Sheet
struct MemberDetailSheet: View {
    let member: CareContact
    var onRemove: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            // Close button
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.primaryText)
                        .frame(width: 32, height: 32)
                        .background(AppTheme.trayIconBackground)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)

            // Member profile
            VStack(spacing: 10) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 72, height: 72)
                    .foregroundStyle(AppTheme.secondaryText)

                Text(member.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.primaryText)

                if !member.phone.isEmpty {
                    Text(member.phone)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }

            // Remove button
            Button(action: {
                onRemove?()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "trash.fill")
                        .font(.caption)
                    Text("Remove from care group")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.red)
            }

            Spacer()
        }
        .background(AppTheme.pageBackground)
    }
}
