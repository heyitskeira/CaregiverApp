import Contacts
import ContactsUI
import SwiftUI

/// Presents the system contact picker (`CNContactPickerViewController`).
/// Does not require Contacts permission — only the user's selection is shared.
struct SystemContactPicker: UIViewControllerRepresentable {
    var onSelect: (CNContact) -> Void
    var onCancel: () -> Void = {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect, onCancel: onCancel)
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        picker.predicateForEnablingContact = NSPredicate(value: true)
        picker.predicateForSelectionOfContact = NSPredicate(value: true)

        let navigationController = UINavigationController(rootViewController: picker)
        navigationController.modalPresentationStyle = .formSheet
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}

    final class Coordinator: NSObject, CNContactPickerDelegate {
        private let onSelect: (CNContact) -> Void
        private let onCancel: () -> Void

        init(onSelect: @escaping (CNContact) -> Void, onCancel: @escaping () -> Void) {
            self.onSelect = onSelect
            self.onCancel = onCancel
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            onSelect(contact)
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            onCancel()
        }
    }
}
