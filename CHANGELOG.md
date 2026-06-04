# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Domain models: `CareTeam`, `UserProfile`, `CareContact`, `CareRecipient`, `CareTask`, `TaskRecurrence`, `TaskAssignment`, `TaskRequest`, `TaskStatus`
- Repository protocols and mock implementations with seed data
- Care Group list, contact editor, settings section, and Contacts import
- Timeline with **All Task** / **My Task** segments wired to `TaskRepository`
- `TimelineStore` and `CareTask+TimelinePresentation` mapping
- Task composer (`TaskSheetView`) saves tasks with multi-assignee support and recurrence
- `HelperPickerView` backed by care group contacts
- Patient Details tab reading from `PatientRepository`
- Custom tab bar shell (`ContentView`) with Timeline, Details, Settings
- Shared `ContactRow`, `ContactAvatarView`, and Contacts picker helpers
- App dependency injection via `AppDependencies` and environment keys
- Supabase Postgres schema (9 tables) with RLS on remote project
- [docs/SUPABASE_BACKEND_PLAN.md](docs/SUPABASE_BACKEND_PLAN.md) — backend rollout guide
- `.gitignore` for Xcode and macOS artifacts

### Changed

- App navigation uses **Timeline**, **Details**, and **Settings** tabs (not separate All Tasks / My Tasks tabs)
- `CareTask` supports `assigneeIDs` (multi-assignee), `careTeamID`, recurrence, and timestamps
- `CareContact` and `CareRecipient` scoped by `careTeamID`
- Add Member opens the system Contacts picker; imported contacts pre-fill the editor
- `MockTaskRepository.saveTask` upserts by id instead of always appending
- README, architecture, collaboration, and care group docs updated for current codebase

### Fixed

- Double chevron on Care Group list rows

### Known gaps (Milestone 2)

- Inbox is static UI (no `TaskRequestRepository` yet)
- Settings profile is hardcoded (no auth session)
- Patient edit / save UI not wired
- iOS app still uses mock repositories (Supabase Swift client not integrated)
