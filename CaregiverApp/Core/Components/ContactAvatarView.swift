import SwiftUI

struct ContactAvatarView: View {
    let contact: CareContact
    var size: CGFloat = 44

    var body: some View {
        Group {
            if let symbol = contact.avatarSymbolName {
                Image(systemName: symbol)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.secondary)
            } else {
                Text(contact.initials)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .background(Color(.secondarySystemBackground))
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
}
