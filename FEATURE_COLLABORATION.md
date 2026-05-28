# Feature Collaboration Guide

## Goal
This document defines how the team should collaborate on Milestone 1 using a feature-wise split for the caregiver task assignment flow.

Milestone 1 scope:
- caregiver opens `All Tasks`
- caregiver creates or edits a task
- caregiver assigns the task to an existing contact from `Settings > Care Group`
- the assigned contact is shown in `All Tasks`
- the same assignment appears in `My Tasks`

Out of scope for this milestone:
- open claim flow
- real-time sync conflict handling
- assistance request flow
- invitation onboarding
- fairness logic for reassignment

## Native iOS Build Rules
To keep the app highly native:
- use `TabView` for the root shell
- use one `NavigationStack` per tab
- use `List` for task collections and contact collections
- use `Form` for `Task Composer` and settings/detail editors
- use `sheet(item:)` for modal task creation and editing
- use `NavigationLink` for deeper settings pages and pickers
- use `DatePicker`, `Picker`, `Menu`, `Toggle`, `TextField`, and `TextEditor` before building custom controls
- use semantic system colors and SF Symbols
- use Dynamic Type text styles instead of hardcoded font sizes

## Feature-Wise Division
Recommended split for 5 people:

### 1. App Shell + Design System
Owns:
- root `TabView`
- per-tab `NavigationStack`
- shared spacing, color, typography, and component rules
- reusable buttons, chips, badges, avatars, and row styling

Suggested files:
- `CaregiverApp/App/AppShellView.swift`
- `CaregiverApp/App/AppTabView.swift`
- `CaregiverApp/App/AppRouter.swift`
- `CaregiverApp/Core/Theme/AppTheme.swift`
- `CaregiverApp/Core/Components/*`

Deliverables:
- working 3-tab shell: `All Tasks`, `My Tasks`, `Settings`
- shared native styling rules
- reusable task row and status badge primitives

### 2. All Tasks
Owns:
- day timeline screen
- date strip
- task list rows
- add/edit entry point into task composer
- assigned-state display

Suggested files:
- `CaregiverApp/Features/AllTasks/AllTasksView.swift`
- `CaregiverApp/Features/AllTasks/AllTasksViewModel.swift`
- `CaregiverApp/Features/AllTasks/Components/DateStrip.swift`
- `CaregiverApp/Features/AllTasks/Components/TaskRow.swift`
- `CaregiverApp/Features/AllTasks/Components/TaskStatusBadge.swift`

Deliverables:
- task list/day timeline
- toolbar add button
- tap row to edit task
- assigned contact visible on each task row

### 3. Task Composer
Owns:
- task create/edit flow
- task form validation
- assignee picker entry
- save/cancel flow

Suggested files:
- `CaregiverApp/Features/TaskComposer/TaskComposerView.swift`
- `CaregiverApp/Features/TaskComposer/TaskComposerViewModel.swift`
- `CaregiverApp/Features/TaskComposer/Components/TaskFormSection.swift`
- `CaregiverApp/Features/TaskComposer/Components/AssigneePicker.swift`
- `CaregiverApp/Features/TaskComposer/Components/InstructionField.swift`

Deliverables:
- modal `Form` with `Task Info`, `Schedule`, `Patient`, `Assign To`, and `Instructions`
- required-field validation
- save task to mock repository

### 4. Settings
Owns:
- `Settings` root screen
- `Patient Details`
- `Profile`
- settings section structure
- navigation into care group and patient detail pages

Suggested files:
- `CaregiverApp/Features/Settings/SettingsView.swift`
- `CaregiverApp/Features/Settings/Sections/ProfileSection.swift`
- `CaregiverApp/Features/Settings/Sections/PatientDetailsSection.swift`
- `CaregiverApp/Features/Settings/PatientDetailView.swift`

Deliverables:
- native grouped settings screen
- patient details available as assignment context
- stable navigation structure for the milestone

### 5. Care Group + Data Contracts + Docs
Owns:
- care group contact list
- contact detail model
- seeded/mock data
- repository protocols and mock repository implementation
- root docs

Suggested files:
- `CaregiverApp/Features/Settings/Sections/CareGroupSection.swift`
- `CaregiverApp/Features/Settings/ContactDetailView.swift`
- `CaregiverApp/Domain/Models/CareTask.swift`
- `CaregiverApp/Domain/Models/CareContact.swift`
- `CaregiverApp/Domain/Models/CareRecipient.swift`
- `CaregiverApp/Infrastructure/Repositories/*`
- `CaregiverApp/Infrastructure/SeedData/*`
- `README.md`
- `docs/ARCHITECTURE.md`
- `CHANGELOG.md`

Deliverables:
- contact list that can be used by `AssigneePicker`
- shared mock data contract
- documentation updated alongside the code

## Shared Contracts To Agree First
Before feature work starts, the team should align on these shared contracts:

### Domain models
- `CareTask`
- `CareContact`
- `CareRecipient`
- `TaskAssignment`

Minimum fields for Milestone 1:
- `CareTask`: `id`, `title`, `scheduledAt`, `duration`, `instructions`, `patientID`, `assigneeID`, `status`
- `CareContact`: `id`, `name`, `relationship`, `phone`, `email`, `avatarName`
- `CareRecipient`: `id`, `name`, `dateOfBirth`, `gender`, `bloodType`, `allergies`, `notes`
- `TaskAssignment`: `taskID`, `assigneeID`, `assignedByID`, `assignedAt`

### UI contracts
- one shared `TaskRow` shape
- one shared status model for `assigned`, `unassigned`, `completed`
- one shared contact row format for both `Care Group` and `AssigneePicker`
- one shared task save interface from `Task Composer`

### Repository contracts
- `TaskRepository`
- `ContactRepository`
- `PatientRepository`

Minimum methods:
- load all tasks
- load my tasks
- save task
- update task
- load contacts
- load patient

## Recommended GitHub Collaboration Flow
Use feature branches with small, reviewable pull requests.

### Branch strategy
- keep `main` always stable
- create one short-lived branch per person
- branch from the latest `main`
- merge back through pull requests only

Recommended branch names:
- `feature/app-shell`
- `feature/all-tasks`
- `feature/task-composer`
- `feature/settings`
- `feature/care-group-data-docs`

If one feature becomes too large, split further:
- `feature/all-tasks-ui`
- `feature/task-composer-assignee-picker`
- `feature/settings-patient-details`

### PR strategy
Each PR should be focused on one feature slice, not a mix of unrelated changes.

Good PR examples:
- `Add app shell and tab navigation`
- `Build All Tasks screen with mock task rows`
- `Add Task Composer form and assignee picker`
- `Build Settings screen with patient detail section`
- `Add care group contacts and mock repositories`

Avoid PRs like:
- `finished most of app`
- `ui fixes and backend and docs`

### Merge order
Merge in this order to reduce conflicts:

1. `App Shell + Design System`
2. `Care Group + Data Contracts + Docs`
3. `Settings`
4. `Task Composer`
5. `All Tasks`
6. `My Tasks`

Reason:
- app shell defines navigation and shared components
- data contracts unblock all feature teams
- settings/care group provides the source contacts
- task composer depends on contacts and task contracts
- all tasks depends on composer entry and task row data
- my tasks can reuse the task row once the shared model is stable

## Daily GitHub Workflow
Each teammate should follow this loop:

1. pull latest `main`
2. create or switch to their feature branch
3. build only their owned files and feature
4. commit in small logical chunks
5. open a pull request early
6. keep rebasing or merging `main` into the branch as shared contracts evolve
7. request review from at least one teammate whose feature depends on the work

Recommended local sequence:
```bash
git checkout main
git pull origin main
git checkout -b feature/task-composer
```

After work:
```bash
git add .
git commit -m "Add task composer form and assignee picker"
git push -u origin feature/task-composer
```

## Code Ownership Rules
To reduce merge conflicts:
- do not edit another person's feature files unless you coordinate first
- shared files in `Core`, `Domain`, and `Infrastructure` need team agreement before structural changes
- if a shared contract must change, update the PR description and notify impacted owners
- prefer adding new files over expanding one giant shared file
- keep views small so ownership remains obvious

## Pull Request Checklist
Every PR should confirm:
- feature matches milestone scope
- UI uses native SwiftUI patterns
- no hardcoded colors that break light/dark mode
- no custom control where `List`, `Form`, `Picker`, or `DatePicker` would work
- accessibility labels exist for icon-only buttons
- preview or mock data included where useful
- docs updated if shared contracts changed

## Review Responsibilities
Suggested reviewer pairing:
- `App Shell` reviews navigation and shared component usage across all PRs
- `Care Group + Data` reviews all model and repository changes
- `Task Composer` reviews task creation and assignment flows
- `All Tasks` reviews task row rendering and task state presentation
- `Settings` reviews settings navigation and patient/contact context

## Conflict Resolution Rules
If two features touch the same area:
- align on the interface first in GitHub comments or a short call
- let one person own the shared file change
- other teammates rebase after that PR merges
- avoid parallel edits in the same shared SwiftUI file where possible

High-risk shared files:
- `AppTabView.swift`
- `TaskRow.swift`
- repository protocols
- seed data models

## Suggested Milestone 1 PR Breakdown
This is the cleanest review sequence:

### PR 1
`App shell, tabs, and shared theme`

### PR 2
`Domain models, mock repositories, and seed data`

### PR 3
`Settings screen with Care Group and Patient Details`

### PR 4
`Task Composer with assignee picker`

### PR 5
`All Tasks screen wired to task creation and editing`

### PR 6
`My Tasks filtered view`

### PR 7
`Docs: README, architecture, changelog`

## Definition of Done for Milestone 1
Milestone 1 is complete when:
- a caregiver can open `All Tasks`
- they can create or edit a task in `Task Composer`
- they can choose an assignee from `Care Group`
- save updates the task with that assignee
- `All Tasks` shows the assignee clearly
- `My Tasks` reflects the assignment using the shared mock data path
- the feature works with native iOS navigation and forms
