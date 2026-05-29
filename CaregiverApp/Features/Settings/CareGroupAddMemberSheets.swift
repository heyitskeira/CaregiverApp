import Contacts
import SwiftUI

extension View {
    func careGroupAddMemberSheets(
        isShowingSystemContactPicker: Binding<Bool>,
        importedDraft: Binding<CareContact?>,
        onSave: @escaping (CareContact) async throws -> Void
    ) -> some View {
        sheet(isPresented: isShowingSystemContactPicker) {
            SystemContactPicker(
                onSelect: { cnContact in
                    isShowingSystemContactPicker.wrappedValue = false
                    importedDraft.wrappedValue = cnContact.toCareContact()
                },
                onCancel: {
                    isShowingSystemContactPicker.wrappedValue = false
                }
            )
            .ignoresSafeArea()
        }
        .sheet(item: importedDraft) { draft in
            NavigationStack {
                ContactDetailView(mode: .imported(draft), onSave: onSave)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                importedDraft.wrappedValue = nil
                            }
                        }
                    }
            }
        }
    }
}
