import SwiftUI

enum ContactEditorMode: Hashable {
    case new
    case edit(CareContact)
    case imported(CareContact)
}

struct ContactDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let mode: ContactEditorMode
    let onSave: (CareContact) async throws -> Void

    @State private var name = ""
    @State private var relationship = "Other"
    @State private var phone = ""
    @State private var email = ""
    @State private var systemContactIdentifier: String?
    @State private var isSaving = false
    @State private var showValidationAlert = false

    private let relationships = ["Daughter", "Son", "Friend", "Sibling", "Other"]

    private var navigationTitle: String {
        switch mode {
        case .new: "Add Member"
        case .edit: "Edit Member"
        case .imported: "Add Member"
        }
    }

    private var existingID: UUID? {
        switch mode {
        case .edit(let contact): contact.id
        case .imported, .new: nil
        }
    }

    var body: some View {
        Form {
            if case .imported = mode {
                Section {
                    Label("Imported from Contacts", systemImage: "person.crop.circle.badge.checkmark")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Contact") {
                TextField("Full name", text: $name)
                    .textContentType(.name)

                Picker("Relationship", selection: $relationship) {
                    ForEach(relationships, id: \.self) { value in
                        Text(value).tag(value)
                    }
                }
            }

            Section("Reach") {
                TextField("Phone", text: $phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)

                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await save() }
                }
                .disabled(isSaving || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onAppear(perform: populateFields)
        .alert("Name required", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Enter a name before saving this care group member.")
        }
    }

    private func populateFields() {
        switch mode {
        case .new:
            break
        case .edit(let contact), .imported(let contact):
            name = contact.name
            relationship = contact.relationship
            phone = contact.phone
            email = contact.email
            systemContactIdentifier = contact.systemContactIdentifier
        }
    }

    private func save() async {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            showValidationAlert = true
            return
        }

        isSaving = true
        defer { isSaving = false }

        let contact = CareContact(
            id: existingID ?? UUID(),
            name: trimmedName,
            relationship: relationship,
            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            systemContactIdentifier: systemContactIdentifier
        )

        do {
            try await onSave(contact)
            dismiss()
        } catch {
            showValidationAlert = true
        }
    }
}
