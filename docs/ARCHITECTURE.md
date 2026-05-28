# Architecture

## Overview

CaregiverApp is a feature-first SwiftUI iOS application. UI talks to repository protocols; Milestone 1 uses mock implementations backed by seed data.

## Navigation

```
TabView
├── All Tasks (NavigationStack)
├── My Tasks (NavigationStack)
└── Settings (NavigationStack)
    └── Care Group (NavigationLink)
        └── Contact detail (Form)
```

## Domain Models

| Model | Role |
|-------|------|
| `CareContact` | Care group member assignable to tasks |
| `CareRecipient` | Patient profile and care context |
| `CareTask` | Scheduled caregiving task |
| `TaskAssignment` | Audit record when a task is assigned |
| `TaskStatus` | `unassigned`, `assigned`, `completed` |

## Repositories

| Protocol | Mock | Methods |
|----------|------|---------|
| `ContactRepository` | `MockContactRepository` | fetch, save, delete |
| `TaskRepository` | `MockTaskRepository` | fetch all, fetch by assignee, save, update |
| `PatientRepository` | `MockPatientRepository` | fetch, save patient |

Repositories are injected via SwiftUI `Environment` from `AppDependencies.live`.

## Native UI Contract

| Screen | SwiftUI primitives |
|--------|-------------------|
| Care Group list | `List`, `searchable`, `NavigationLink`, swipe delete |
| Contact editor | `Form`, `TextField`, `Picker`, toolbar Save |
| Settings section | `Section`, `NavigationLink`, horizontal preview strip |

## Production Backend (planned)

- Supabase Auth for sign-in
- Postgres for relational care data
- Realtime for task assignment updates
- APNs for notifications

Milestone 1 intentionally uses mocks so UI teams can proceed in parallel.
