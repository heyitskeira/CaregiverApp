# Feature Collaboration Guide

## Goal

This document defines how the team collaborates on CaregiverApp. **Milestone 1 is largely complete** on `main`; use this guide for remaining work, reviews, and Milestone 2 (Supabase + auth).

## Milestone 1 scope

A caregiver can:

1. Open **Timeline → All Task**
2. Create a task with the **+** button
3. Assign helpers from **Settings → Care Group**
4. See assignees on the timeline (initials, repeat icon, unassigned badge)
5. Switch to **My Task** to see tasks assigned to the current member (mock viewer: Lily via `SeedData.myTasksViewerContactID`)

### Milestone 1 status

| Area | Owner area | Status |
|------|------------|--------|
| App shell + tab bar | App Shell | Done — `ContentView.swift` |
| Care group + data contracts | Care Group / Data | Done |
| Settings + patient read | Settings | Done (profile header still hardcoded) |
| Task composer | Task Composer | Done |
| Timeline (All / My Task) | Timeline | Done |
| Inbox | Inbox | Stub — static UI |

### Out of scope (Milestone 2+)

- Real auth and signed-in user for My Task filtering
- Supabase sync and Realtime
- Inbox accept/decline backed by `TaskRequestRepository`
- Patient edit / save UI
- Push notifications

## Current codebase map

The repo uses these paths (not the original suggested names):

| Area | Actual paths |
|------|----------------|
| App shell | `ContentView.swift`, `CaregiverAppApp.swift` |
| Timeline | `Features/Timeline/TimelineView.swift`, `TimelineStore.swift` |
| Task composer | `Features/Tasks/TaskSheetView.swift`, `HelperPickerView.swift` |
| Settings | `Features/Settings/SettingsRootView.swift` |
| Patient details | `Features/Details/PatientDetailsTabView.swift` |
| Care group | `Features/Settings/CareGroupListView.swift`, `CareGroupSection.swift` |
| Domain + mocks | `Domain/`, `Infrastructure/` |

## Shared contracts (current)

### Domain models

Source of truth: `CaregiverApp/Domain/Models/`

- `CareTask`: `assigneeIDs: [UUID]` (multi-assignee), `careTeamID`, `recurrence`, `createdByID`, timestamps
- `CareContact`: `careTeamID`, `linkedUserID?`, `systemContactIdentifier?`
- `CareRecipient`: `careTeamID`
- `TaskRecurrence`, `TaskRequest`, `TaskAssignment`, `CareTeam`, `UserProfile`

Do **not** change model shapes without team agreement and doc updates.

### Repository protocols

- `TaskRepository` — `fetchAllTasks`, `fetchTasks(assigneeID:)`, `saveTask`, `updateTask`, `deleteTask`
- `ContactRepository` — `fetchContacts`, `contact(id:)`, `saveContact`, `deleteContact`
- `PatientRepository` — `fetchPatient`, `savePatient`

Injected via `@Environment(\.taskRepository)` etc. from `AppDependencies.live`.

### UI contracts

- **Assignee selection:** `ContactRepository.fetchContacts()` + `ContactRow` / `HelperPickerView`
- **Task persistence:** build `CareTask` → `TaskRepository.saveTask`
- **Timeline display:** `CareTask.timelinePresentation(contactsByID:)` → `TimelineTaskModel`

## Native iOS build rules

- One `NavigationStack` per tab
- Use `List`, `Form`, `DatePicker`, `Picker`, `Menu`, `TextField` before custom controls
- Use semantic system colors and SF Symbols
- Use Dynamic Type text styles instead of hardcoded font sizes
- Add accessibility labels for icon-only buttons

## GitHub workflow

### Branch strategy

- Keep `main` stable and buildable
- One short-lived branch per feature or fix
- Branch from latest `main`
- Merge via pull requests only

Recommended branch names for **remaining work**:

- `feature/inbox-task-requests`
- `feature/patient-edit`
- `feature/supabase-auth`
- `feature/supabase-repositories`
- `fix/timeline-date-picker`

### Daily loop

```bash
git checkout main
git pull origin main
git checkout -b feature/your-feature
# … work …
git add .
git commit -m "Describe why, not just what"
git push -u origin feature/your-feature
gh pr create --title "…" --body "…"
```

### What not to commit

- `xcuserdata/`, `*.xcuserstate`, `.DS_Store` (covered by `.gitignore`)
- Supabase `service_role` keys or `.env` files
- Personal Xcode scheme changes unless intentional for the team

## Code ownership (Milestone 2)

| Workstream | Suggested owner focus | Key files |
|------------|----------------------|-----------|
| Supabase auth | Auth + onboarding | New `Features/Auth/`, `Infrastructure/Supabase/` |
| Supabase repos | Replace mocks | `Infrastructure/Repositories/Supabase*.swift` |
| Inbox | Task requests | `Features/Inbox/`, new `TaskRequestRepository` |
| Patient edit | Details tab write | `Features/Details/` |
| Realtime | Live timeline | `TimelineStore` subscriptions |

**Shared files** (`Domain/`, `Infrastructure/SeedData/`, `App/AppDependencies.swift`) require agreement before structural changes.

## Pull request checklist

Every PR should confirm:

- [ ] Builds in Xcode (⌘R on simulator)
- [ ] Matches agreed milestone scope
- [ ] Uses native SwiftUI patterns
- [ ] Accessibility labels on icon-only buttons
- [ ] No secrets in diff
- [ ] Docs updated if shared contracts changed (`README.md`, `CHANGELOG.md`, `docs/ARCHITECTURE.md`)

## Suggested Milestone 2 PR sequence

1. **Add supabase-swift + config** — SPM package, client factory, no UI change
2. **Auth shell** — sign in with Apple or email OTP; `SessionStore`
3. **Supabase contact + patient repos** — replace mocks for care group and details
4. **Supabase task repo** — replace mock; seed team on first login
5. **Inbox + TaskRequestRepository** — wire accept/decline
6. **Realtime subscriptions** — live timeline updates

See [docs/SUPABASE_BACKEND_PLAN.md](docs/SUPABASE_BACKEND_PLAN.md) for schema and RLS details.

## Review pairing

- **Data / Domain** reviews all model and repository changes
- **Timeline** reviews task display and `TimelineStore`
- **Task composer** reviews save flow and assignee wiring
- **Settings / Care group** reviews contact CRUD and navigation

## Definition of done — Milestone 1

- [x] Caregiver opens Timeline → All Task
- [x] Creates a task via + button
- [x] Assigns helpers from Care Group
- [x] Assignee visible on timeline
- [x] My Task shows filtered assignments (mock viewer)
- [ ] Inbox functional *(deferred)*
- [ ] Auth / remote sync *(Milestone 2)*

## Docs index

| Doc | Purpose |
|-----|---------|
| [README.md](README.md) | Project overview and quick start |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Navigation, data flow, file map |
| [docs/SUPABASE_BACKEND_PLAN.md](docs/SUPABASE_BACKEND_PLAN.md) | Postgres schema and iOS backend rollout |
| [docs/CARE_GROUP_IMPLEMENTATION.md](docs/CARE_GROUP_IMPLEMENTATION.md) | Care group feature reference |
| [CHANGELOG.md](CHANGELOG.md) | Release notes |
