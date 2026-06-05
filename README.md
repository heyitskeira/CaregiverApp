# CaregiverApp

A native iOS app that helps primary caregivers coordinate daily caregiving tasks with family and friends.

## Problem

Caregivers often carry the full mental load of scheduling, delegating, and following up on care tasks. This app gives them a simple way to assign responsibilities and see who is accountable for each task.

## Milestone 1

The current milestone proves one flow:

1. Open **Timeline → All Task**
2. Create a task with the **+** button
3. Assign helpers from **Settings → Care Group**
4. See assignees reflected on the timeline (initials, repeat icon, unassigned badge)
5. Switch to **My Task** to see tasks assigned to the current member

### Status

| Area | Status |
|------|--------|
| Care group CRUD | Done — contacts picker, list, edit, delete |
| Patient profile (Details tab) | Done — read from `PatientRepository` |
| Task timeline | Done — `TaskRepository` + `TimelineStore` |
| Task composer | Done — saves `CareTask` with assignees and recurrence |
| Inbox | Stub — static UI |
| Auth / remote sync | Next — Supabase schema ready, iOS client not wired yet |

## App Structure

| Tab | Purpose |
|-----|---------|
| **Timeline** | Daily schedule with **All Task** and **My Task** segments; inbox link in header |
| **Details** | Patient health profile |
| **Settings** | Profile, care group, preferences |

Care group members live under **Settings**, not as a top-level tab.

## Tech Stack

- **UI:** SwiftUI (`NavigationStack`, `List`, `Form`, custom tab bar)
- **State:** `@Observable` feature stores (`CareGroupStore`, `TimelineStore`)
- **Data (Milestone 1):** Mock repositories + seed data
- **Backend:** Supabase Postgres with RLS (schema applied); Auth, Realtime, and push planned

## Domain Models

| Model | Role |
|-------|------|
| `CareTeam` | Household scope for patient, contacts, and tasks |
| `UserProfile` | Signed-in caregiver |
| `CareContact` | Care group member assignable to tasks |
| `CareRecipient` | Patient profile |
| `CareTask` | Scheduled task (multi-assignee, recurrence) |
| `TaskRecurrence` | Repeat schedule |
| `TaskAssignment` | Assignment audit record |
| `TaskRequest` | Inbox volunteer request |
| `TaskStatus` | `unassigned`, `assigned`, `completed` |

## Project Layout

```
CaregiverApp/
  App/                 App shell, dependencies, environment keys
  Core/                Shared UI and Contacts import helpers
  Domain/
    Models/            Entities (CareTask, CareContact, …)
    Repositories/      Protocol definitions
  Infrastructure/
    Repositories/      Mock implementations
    SeedData/          Development seed data
  Features/
    Timeline/          All Task / My Task views, TimelineStore
    Tasks/             Task composer, helper picker
    Details/           Patient profile tab
    Settings/          Care group, preferences
    Inbox/             Task request inbox (stub)
```

## Run

1. Clone the repo and open `CaregiverApp.xcodeproj` in Xcode
2. Select an iOS Simulator
3. Run (⌘R)

No external dependencies or API keys required for Milestone 1 (mock data only).

## Contributing

See [FEATURE_COLLABORATION.md](FEATURE_COLLABORATION.md) for branch strategy, PR checklist, and Milestone 2 workstreams. Update [CHANGELOG.md](CHANGELOG.md) when shipping user-visible changes.

## Key Integrations

### Care Group

- `Features/Settings/CareGroupListView.swift` — list, search, add from Contacts, edit, delete
- `Features/Settings/Sections/CareGroupSection.swift` — embeddable settings preview
- `Domain/Models/CareContact.swift` — contact model
- `Infrastructure/Repositories/MockContactRepository.swift` — in-memory store

Use `ContactRepository.fetchContacts()` and `ContactRow` for assignee selection.

### Tasks

- `Features/Timeline/TimelineView.swift` — loads tasks via `TimelineStore`
- `Features/Tasks/TaskSheetView.swift` — creates tasks via `TaskRepository.saveTask`
- `Features/Tasks/HelperPickerView.swift` — assignee picker backed by care group contacts

## Backend (Supabase)

Postgres schema and RLS policies are applied to the linked Supabase project (9 tables). The iOS app still uses mock repositories until Phase A (supabase-swift + auth) is implemented.

See [docs/SUPABASE_BACKEND_PLAN.md](docs/SUPABASE_BACKEND_PLAN.md) for the full schema, security model, and rollout phases.

## Docs

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — architecture overview
- [docs/SUPABASE_BACKEND_PLAN.md](docs/SUPABASE_BACKEND_PLAN.md) — Supabase schema and migration plan
- [docs/CARE_GROUP_IMPLEMENTATION.md](docs/CARE_GROUP_IMPLEMENTATION.md) — care group build guide
- [FEATURE_COLLABORATION.md](FEATURE_COLLABORATION.md) — team split and GitHub workflow
- [CHANGELOG.md](CHANGELOG.md) — release notes
