import Contacts

extension CNContact {
    func toCareContact(relationship defaultRelationship: String = "Other") -> CareContact {
        let fullName = CNContactFormatter.string(from: self, style: .fullName)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let fallbackName = [givenName, familyName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return CareContact(
            name: fullName.isEmpty ? fallbackName : fullName,
            relationship: defaultRelationship,
            phone: primaryPhone,
            email: primaryEmail,
            systemContactIdentifier: identifier
        )
    }

    private var primaryPhone: String {
        phoneNumbers.first?.value.stringValue ?? ""
    }

    private var primaryEmail: String {
        emailAddresses.first?.value as String? ?? ""
    }
}
