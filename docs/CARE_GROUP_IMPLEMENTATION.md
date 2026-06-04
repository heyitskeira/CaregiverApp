# Care Group — Implementation Reference

Care group lets the primary caregiver manage family and friends who can be assigned to tasks. This doc describes the **implemented** feature; source code is the source of truth.

## Related docs

- [ARCHITECTURE.md](ARCHITECTURE.md) — app-wide navigation and data flow
- [SUPABASE_BACKEND_PLAN.md](SUPABASE_BACKEND_PLAN.md) — `care_contacts` table and RLS
- [FEATURE_COLLABORATION.md](../FEATURE_COLLABORATION.md) — team workflow

## File map

```
CaregiverApp/
  Domain/Models/CareContact.swift
  Domain/Repositories/ContactRepository.swift
  Infrastructure/Repositories/MockContactRepository.swift
  Infrastructure/SeedData/SeedData.swift
  Core/Components/ContactRow.swift
  Core/Components/ContactAvatarView.swift
  Core/Contacts/CNContact+CareContact.swift
  Core/Contacts/SystemContactPicker.swift
  Features/Settings/
    CareGroupStore.swift
    CareGroupListView.swift
    CareGroupAddMemberSheets.swift
    ContactDetailView.swift
    Sections/CareGroupSection.swift
  Features/Tasks/HelperPickerView.swift
```

## Model: `CareContact`

| Field | Type | Notes |
|-------|------|-------|
| `id` | `UUID` | Stable in seed data |
| `careTeamID` | `UUID` | Scopes contact to a household |
| `name` | `String` | Required |
| `relationship` | `String` | e.g. Daughter, Son, Friend |
| `phone` | `String` | |
| `email` | `String` | |
| `avatarSymbolName` | `String?` | SF Symbol override |
| `systemContactIdentifier` | `String?` | Set when imported from Contacts |
| `linkedUserID` | `UUID?` | Set when contact joins the app (Milestone 2) |

Computed: `initials` for avatar display.

## Repository: `ContactRepository`

```swift
protocol ContactRepository: Sendable {
    func fetchContacts() async throws -> [CareContact]
    func contact(id: UUID) async throws -> CareContact?
    func saveContact(_ contact: CareContact) async throws
    func deleteContact(id: UUID) async throws
}
```

`MockContactRepository` upserts by `id` and deduplicates by `systemContactIdentifier` within a team.

## Seed data

`SeedData.contacts` — Lily, James, Anna — all scoped to `SeedData.careTeamID`. Stable UUIDs let tasks reference assignees consistently.

## UI flows

### Settings preview (`CareGroupSection`)

- Shows up to 3 members in a horizontal strip
- **View All** → `CareGroupListView`
- **Add from Contacts** → system picker → confirm in `ContactDetailView`

### Full list (`CareGroupListView`)

- Searchable `List` with swipe-to-delete
- **+** toolbar → Contacts picker
- Tap row → edit in `ContactDetailView`
- Uses `CareGroupStore` for load / save / delete

### Contact editor (`ContactDetailView`)

Modes: `.new`, `.edit(CareContact)`, `.imported(CareContact)`

Requires `careTeamID` (currently `SeedData.careTeamID` in Milestone 1). Validates non-empty name before save.

### Assignee picker (`HelperPickerView`)

Used by `TaskSheetView`. Loads contacts via `ContactRepository.fetchContacts()`. Excludes already-assigned IDs.

## Integration for teammates

| Consumer | How to use |
|----------|------------|
| Task composer | `HelperPickerView` or `fetchContacts()` + `ContactRow` |
| Timeline | Resolve assignee initials via `contact(id:)` or contacts map |
| New features | Inject `@Environment(\.contactRepository)` |

Environment is set in `CaregiverAppApp.swift`:

```swift
ContentView()
    .environment(\.contactRepository, dependencies.contactRepository)
    .environment(\.taskRepository, dependencies.taskRepository)
    .environment(\.patientRepository, dependencies.patientRepository)
```

## Contacts import

1. `SystemContactPicker` wraps `CNContactPickerViewController`
2. `CNContact.toCareContact(careTeamID:)` maps fields
3. `careGroupAddMemberSheets` modifier presents picker + imported draft editor

## Milestone 1 checklist

- [x] Domain model and repository compile
- [x] Mock CRUD works
- [x] List shows seeded contacts
- [x] Add from Contacts persists
- [x] Edit and swipe delete work
- [x] `CareGroupSection` embeds in Settings
- [x] `ContactRow` reused in assignee picker
- [x] Environment injection at app root

## Milestone 2 (Supabase)

- Replace `MockContactRepository` with Supabase implementation
- Filter by authenticated user's `care_team_id`
- Link `linkedUserID` when helpers accept invites
- See [SUPABASE_BACKEND_PLAN.md](SUPABASE_BACKEND_PLAN.md) § Phase B

## PR template

**Title:** `Add / update care group …`

**Test plan:**

- [ ] Open Settings → Care Group → View All
- [ ] Add member from Contacts; confirm name and relationship save
- [ ] Edit existing member
- [ ] Swipe delete removes member
- [ ] Create task → Add Helper → seeded contacts appear
