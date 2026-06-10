# Architecture

## Overview

CaregiverApp is a feature-first SwiftUI iOS application. UI talks to repository protocols; Milestone 1 uses mock implementations backed by seed data. e Postgres schema and RLS are applied on the remote project; the iOS client will connect in Milestone 2.

## Navigation

```
ContentView (custom tab bar + FAB)
├── Timeline (NavigationStack)
│   ├── All Task / My Task segments
│   ├── Task rows from TaskRepository
│   └── Inbox (NavigationLink — stub)
├── Details (NavigationStack)
│   └── PatientDetailsTabView
└── Settings (NavigationStack)
    ├── Profile header (hardcoded — Milestone 2)
    ├── Care Group (NavigationLink → CareGroupListView)
    │   └── ContactDetailView (Form)
    └── Preferences (Notification, Language, Privacy)

FAB (+) → TaskSheetView (sheet)
```

## Data Flow

```
CaregiverAppApp
  └── AppDependencies.live
        ├── contactRepository → CareGroupStore, HelperPickerView
        ├── taskRepository    → TimelineStore, TaskSheetView
        └── patientRepository → PatientDetailsTabView
```

| Feature | Store / view | Repository |
|---------|--------------|------------|
| Care group | `CareGroupStore` | `ContactRepository` |
| Timeline | `TimelineStore` | `TaskRepository`, `ContactRepository` |
| Task composer | `TaskSheetView` | `TaskRepository`, `ContactRepository` |
| Patient details | `PatientDetailsTabView` | `PatientRepository` |
| Inbox | `InboxView` | *(not wired)* |

Repositories are injected via SwiftUI `Environment` from `AppDependencies.live` in `CaregiverAppApp.swift`.

## Domain Models

| Model | Role |
|-------|------|
| `CareTeam` | Household scope for patient, contacts, and tasks |
| `UserProfile` | Signed-in caregiver (maps to e `profiles`) |
| `CareContact` | Care group member assignable to tasks |
| `CareRecipient` | Patient profile and care context |
| `CareTask` | Scheduled caregiving task (multi-assignee, recurrence) |
| `TaskRecurrence` | Repeat schedule on a task |
| `TaskAssignment` | Audit record when a task is assigned |
| `TaskRequest` | Inbox volunteer request for an unassigned task |
| `TaskStatus` | `unassigned`, `assigned`, `completed` |

See [E_BACKEND_PLAN.md](E_BACKEND_PLAN.md) for Postgres schema and rollout phases.

## Repositories

| Protocol | Mock | Methods | Wired in UI |
|----------|------|---------|-------------|
| `ContactRepository` | `MockContactRepository` | fetch, save, delete | Yes |
| `TaskRepository` | `MockTaskRepository` | fetch all, fetch by assignee, save, update, delete | Yes |
| `PatientRepository` | `MockPatientRepository` | fetch, save patient | Read only |

## Native UI Contract

| Screen | SwiftUI primitives |
|--------|-------------------|
| Timeline | `ScrollView`, segmented control, custom task rows |
| Task composer | `Form`, `DatePicker`, `Menu`, sheet |
| Care Group list | `List`, `searchable`, `NavigationLink`, swipe delete |
| Contact editor | `Form`, `TextField`, `Picker`, toolbar Save |
| Settings section | `List`, `Section`, `NavigationLink`, horizontal preview strip |
| Patient details | `List`, labeled rows |

## Backend

| Layer | Status |
|-------|--------|
| e Postgres schema | Applied (9 tables) |
| Row Level Security | Enabled on all tables |
| e Auth | Planned — Milestone 2 |
| e-swift in iOS | Planned — Milestone 2 |
| Realtime | Planned — Milestone 3 |
| APNs push | Planned — Milestone 3 |

Milestone 1 intentionally uses mocks so UI work could proceed in parallel. Replace mocks with e repository implementations per [E_BACKEND_PLAN.md](E_BACKEND_PLAN.md).

## File Map (source of truth)

```
CaregiverApp/
  App/                    AppDependencies, RepositoryEnvironment
  Core/                   ContactRow, Contacts import
  Domain/Models/          All entities
  Domain/Repositories/    Protocol definitions
  Infrastructure/         Mocks + SeedData
  Features/
    Timeline/             TimelineView, TimelineStore, presentation mapping
    Tasks/                  TaskSheetView, HelperPickerView
    Details/                PatientDetailsTabView
    Settings/               Care group, preferences
    Inbox/                  InboxView (stub)
  ContentView.swift       Root tab shell
  CaregiverAppApp.swift     @main entry
```
