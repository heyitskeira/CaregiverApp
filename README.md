# CaregiverApp

A native iOS app that helps primary caregivers coordinate daily caregiving tasks with family and friends.

## Problem

Caregivers often carry the full mental load of scheduling, delegating, and following up on care tasks. This app gives them a simple way to assign responsibilities and see who is accountable for each task.

## Milestone 1

The current milestone proves one flow:

1. Open **All Tasks**
2. Create or edit a task
3. Assign it to a contact from **Settings → Care Group**
4. See the assignee reflected in task views

## App Structure

| Tab | Purpose |
|-----|---------|
| **All Tasks** | Shared timeline of caregiving tasks |
| **My Tasks** | Tasks for the signed-in member |
| **Settings** | Patient details, care group, profile, preferences |

Care group members live under **Settings**, not as a top-level tab.

## Tech Stack

- **UI:** SwiftUI (`TabView`, `NavigationStack`, `List`, `Form`)
- **State:** `@Observable` feature stores
- **Data (Milestone 1):** Mock repositories + seed data
- **Backend (planned):** Supabase (Auth, Postgres, Realtime, push)

## Project Layout

```
CaregiverApp/
  App/                 App shell, dependencies, environment
  Core/                Shared UI components
  Domain/              Models and repository protocols
  Infrastructure/      Mock repositories and seed data
  Features/            Feature screens (AllTasks, Settings, …)
```

## Run

1. Open `CaregiverApp.xcodeproj` in Xcode
2. Select an iOS Simulator
3. Run (⌘R)

## Care Group (Feature #5)

Implemented in:

- `Features/Settings/CareGroupListView.swift` — list, search, add, edit, delete
- `Features/Settings/Sections/CareGroupSection.swift` — embeddable settings section
- `Domain/Models/CareContact.swift` — contact model
- `Infrastructure/Repositories/MockContactRepository.swift` — in-memory store

Teammates integrating assignee selection should use `ContactRepository.fetchContacts()` and `ContactRow`.

## Docs

- [FEATURE_COLLABORATION.md](FEATURE_COLLABORATION.md) — team split and GitHub workflow
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — architecture overview
- [docs/CARE_GROUP_IMPLEMENTATION.md](docs/CARE_GROUP_IMPLEMENTATION.md) — care group build guide
- [CHANGELOG.md](CHANGELOG.md) — release notes

## Branch

Care group work: `feature/care-group-data-docs`
