import SwiftUI

struct ContactRow: View {
    let contact: CareContact
    var showsChevron = false
    var isSelected = false

    var body: some View {
        HStack(spacing: 12) {
            ContactAvatarView(contact: contact)

            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.headline)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
            } else if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var subtitle: String {
        if contact.phone.isEmpty {
            return contact.relationship
        }
        return "\(contact.relationship) · \(contact.phone)"
    }

    private var accessibilityLabel: String {
        if contact.phone.isEmpty {
            return "\(contact.name), \(contact.relationship)"
        }
        return "\(contact.name), \(contact.relationship), \(contact.phone)"
    }
}
