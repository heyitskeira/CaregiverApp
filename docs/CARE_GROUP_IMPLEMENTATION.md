# Care Group Feature — Implementation Guide (Feature #5)

This guide is the source of truth for building the Care Group slice. Copy each file into the paths below. Xcode auto-includes anything under `CaregiverApp/`.

## What You Own

- Domain models and repository protocols
- Mock repositories + seed data
- Shared `ContactRow` / `ContactAvatarView`
- `CareGroupListView`, `CareGroupSection`, `ContactDetailView`
- `README.md`, `docs/ARCHITECTURE.md`, `CHANGELOG.md` (sections at bottom)

## File Tree

```
CaregiverApp/
  App/
    AppDependencies.swift
    RepositoryEnvironment.swift
  Domain/
    Models/
      TaskStatus.swift
      CareContact.swift
      CareRecipient.swift
      CareTask.swift
      TaskAssignment.swift
    Repositories/
      ContactRepository.swift
      TaskRepository.swift
      PatientRepository.swift
  Infrastructure/
    SeedData/
      SeedData.swift
    Repositories/
      MockContactRepository.swift
      MockTaskRepository.swift
      MockPatientRepository.swift
  Core/
    Components/
      ContactAvatarView.swift
      ContactRow.swift
  Features/
    Settings/
      CareGroupListView.swift
      ContactDetailView.swift
      CareGroupStore.swift
      Sections/
        CareGroupSection.swift
```

## Integration Points for Teammates

| Consumer | Uses |
|----------|------|
| Settings (#4) | Embed `CareGroupSection()` in `SettingsView` |
| Task Composer (#3) | `ContactRepository.fetchContacts()` + `ContactRow` in assignee picker |
| All Tasks (#2) | Resolve `assigneeID` via `contact(id:)` |
| App Shell (#1) | Inject `AppDependencies.live` at app root |

Temporary dev entry (until Settings lands):

```swift
// CaregiverAppApp.swift
WindowGroup {
    NavigationStack {
        CareGroupListView()
    }
    .environment(\.contactRepository, AppDependencies.live.contactRepository)
    .environment(\.taskRepository, AppDependencies.live.taskRepository)
    .environment(\.patientRepository, AppDependencies.live.patientRepository)
}
```

---

## Domain Models

### `Domain/Models/TaskStatus.swift`

```swift
import Foundation

enum TaskStatus: String, Codable, Sendable, CaseIterable {
    case unassigned
    case assigned
    case completed
}
```

### `Domain/Models/CareContact.swift`

```swift
import Foundation

struct CareContact: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var name: String
    var relationship: String
    var phone: String
    var email: String
    var avatarSymbolName: String?

    init(
        id: UUID = UUID(),
        name: String,
        relationship: String,
        phone: String = "",
        email: String = "",
        avatarSymbolName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.phone = phone
        self.email = email
        self.avatarSymbolName = avatarSymbolName
    }

    var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap(\.first)
        if letters.isEmpty, let first = name.first {
            return String(first).uppercased()
        }
        return letters.map { String($0).uppercased() }.joined()
    }
}
```

### `Domain/Models/CareRecipient.swift`

```swift
import Foundation

struct CareRecipient: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var name: String
    var dateOfBirth: Date
    var gender: String
    var bloodType: String
    var allergies: String
    var favoriteFood: String
    var healthNotes: String
}
```

### `Domain/Models/CareTask.swift`

```swift
import Foundation

struct CareTask: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    var title: String
    var scheduledAt: Date
    var durationMinutes: Int
    var instructions: String
    var patientID: UUID
    var assigneeID: UUID?
    var status: TaskStatus
}
```

### `Domain/Models/TaskAssignment.swift`

```swift
import Foundation

struct TaskAssignment: Identifiable, Hashable, Codable, Sendable {
    let id: UUID
    let taskID: UUID
    let assigneeID: UUID
    let assignedByID: UUID
    let assignedAt: Date
}
```

---

## Repository Protocols

### `Domain/Repositories/ContactRepository.swift`

```swift
import Foundation

protocol ContactRepository: Sendable {
    func fetchContacts() async throws -> [CareContact]
    func contact(id: UUID) async throws -> CareContact?
    func saveContact(_ contact: CareContact) async throws
    func deleteContact(id: UUID) async throws
}
```

### `Domain/Repositories/TaskRepository.swift`

```swift
import Foundation

protocol TaskRepository: Sendable {
    func fetchAllTasks() async throws -> [CareTask]
    func fetchTasks(assigneeID: UUID) async throws -> [CareTask]
    func saveTask(_ task: CareTask) async throws
    func updateTask(_ task: CareTask) async throws
    func deleteTask(id: UUID) async throws
}
```

### `Domain/Repositories/PatientRepository.swift`

```swift
import Foundation

protocol PatientRepository: Sendable {
    func fetchPatient() async throws -> CareRecipient?
    func savePatient(_ patient: CareRecipient) async throws
}
```

---

## Seed Data

### `Infrastructure/SeedData/SeedData.swift`

Use stable UUIDs so tasks and assignments reference the same contacts across mocks.

```swift
import Foundation

enum SeedData {
    static let patientID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let lilyID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let jamesID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    static let annaID = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!

    static let patient = CareRecipient(
        id: patientID,
        name: "Grandma Marie",
        dateOfBirth: Calendar.current.date(from: DateComponents(year: 1946, month: 4, day: 21))!,
        gender: "Female",
        bloodType: "O+",
        allergies: "Penicillin",
        favoriteFood: "Pizza",
        healthNotes: "Regular check-ups every two months."
    )

    static let contacts: [CareContact] = [
        CareContact(
            id: lilyID,
            name: "Lily",
            relationship: "Daughter",
            phone: "+62 123-456-789",
            email: "lily@example.com"
        ),
        CareContact(
            id: jamesID,
            name: "James",
            relationship: "Son",
            phone: "+62 123-456-790",
            email: "james@example.com"
        ),
        CareContact(
            id: annaID,
            name: "Anna",
            relationship: "Friend",
            phone: "+62 123-456-791",
            email: "anna@example.com"
        ),
    ]
}
```

---

## Mock Repositories

### `Infrastructure/Repositories/MockContactRepository.swift`

```swift
import Foundation

@MainActor
final class MockContactRepository: ContactRepository {
    private var contacts: [CareContact]

    init(contacts: [CareContact] = SeedData.contacts) {
        self.contacts = contacts
    }

    func fetchContacts() async throws -> [CareContact] {
        contacts.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func contact(id: UUID) async throws -> CareContact? {
        contacts.first { $0.id == id }
    }

    func saveContact(_ contact: CareContact) async throws {
        if let index = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[index] = contact
        } else {
            contacts.append(contact)
        }
    }

    func deleteContact(id: UUID) async throws {
        contacts.removeAll { $0.id == id }
    }
}
```

Implement `MockTaskRepository` and `MockPatientRepository` similarly with in-memory arrays seeded from `SeedData`.

---

## App Wiring

### `App/AppDependencies.swift`

```swift
import Foundation

@MainActor
struct AppDependencies {
    let contactRepository: any ContactRepository
    let taskRepository: any TaskRepository
    let patientRepository: any PatientRepository

    static let live = AppDependencies(
        contactRepository: MockContactRepository(),
        taskRepository: MockTaskRepository(),
        patientRepository: MockPatientRepository()
    )
}
```

### `App/RepositoryEnvironment.swift`

```swift
import SwiftUI

private struct ContactRepositoryKey: EnvironmentKey {
    @MainActor static let defaultValue: any ContactRepository = MockContactRepository()
}

extension EnvironmentValues {
    var contactRepository: any ContactRepository {
        get { self[ContactRepositoryKey.self] }
        set { self[ContactRepositoryKey.self] = newValue }
    }
}
```

Repeat for `taskRepository` and `patientRepository`.

---

## Shared UI

### `Core/Components/ContactAvatarView.swift`

- Circle with `Color(.secondarySystemBackground)`
- Show `Image(systemName:)` if `avatarSymbolName` set, else initials
- `.font(.subheadline.weight(.semibold))`, `.foregroundStyle(.secondary)`

### `Core/Components/ContactRow.swift`

Props: `contact`, optional `showsChevron`, optional `isSelected` (checkmark).

Native `List` row layout:
- Leading: `ContactAvatarView`
- Title: name (`.headline`)
- Subtitle: relationship + phone (`.subheadline`, `.secondary`)

---

## Care Group Screens

### `Features/Settings/CareGroupStore.swift`

`@Observable @MainActor` class:
- `contacts: [CareContact]`
- `isLoading`, `errorMessage`
- `load()`, `delete(id:)`, `save(_:)`
- Injected `contactRepository` in `init`

### `Features/Settings/CareGroupListView.swift`

Native patterns:
- `NavigationStack` (if not already inside one)
- `navigationTitle("Care Group")`
- `.searchable(text: $searchText)`
- `List` with `ForEach` → `NavigationLink` to `ContactDetailView(contact:)`
- Toolbar `+` → `ContactDetailView(mode: .new)`
- `.swipeActions` delete
- `ContentUnavailableView` when empty
- `.task { await store.load() }`

### `Features/Settings/ContactDetailView.swift`

Present as pushed screen (not sheet for add/edit in list flow).

`Form` sections:
- **Contact**: name `TextField`
- **Relationship**: `Picker` or `TextField` (Daughter, Son, Friend, Other)
- **Phone / Email**: `TextField` with `.keyboardType`
- Toolbar: Cancel (if modal) / Save

`enum ContactEditorMode { case new, edit(CareContact) }`

On save: validate non-empty name → `store.save` → `dismiss()`.

### `Features/Settings/Sections/CareGroupSection.swift`

For Settings root (#4):

```swift
Section {
    NavigationLink {
        CareGroupListView()
    } label: {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Care Group")
                Spacer()
                Text("View All")
                    .font(.subheadline)
                    .foregroundStyle(.green)
            }
            CareGroupPreviewStrip(contacts: previewContacts)
        }
    }
} header: {
    Text("Care Group")
}
```

`CareGroupPreviewStrip`: horizontal `ScrollView` with avatar + name + relationship (matches profile mockup).

Load preview via `.task` with `@Environment(\.contactRepository)` — first 3 contacts.

---

## Milestone 1 Checklist

- [ ] All domain models compile
- [ ] `MockContactRepository` CRUD works
- [ ] `CareGroupListView` lists seeded Lily, James, Anna
- [ ] Add contact persists in mock store
- [ ] Edit contact updates list
- [ ] Delete via swipe removes contact
- [ ] `CareGroupSection` embeddable in Settings
- [ ] `ContactRow` reusable for AssigneePicker (#3)
- [ ] Environment injection documented for App Shell (#1)

## PR Suggestion

Branch: `feature/care-group-data-docs`

Title: `Add care group contacts, domain contracts, and mock repositories`

Merge before: Task Composer, All Tasks (they depend on contact IDs and repository).
