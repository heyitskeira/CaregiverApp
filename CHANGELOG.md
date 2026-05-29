# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Domain models: `CareContact`, `CareRecipient`, `CareTask`, `TaskAssignment`, `TaskStatus`
- Repository protocols and mock implementations with seed data
- Care Group list, contact editor, and settings section UI
- Shared `ContactRow` and `ContactAvatarView` components
- App dependency injection via `AppDependencies` and environment keys
- Temporary 3-tab shell with Settings hosting Care Group
- README, architecture doc, and collaboration guides

### Changed

- Add Member now opens the system Contacts picker (`CNContactPickerViewController`) instead of a blank manual form
- Imported contacts are pre-filled; user confirms relationship and saves
- `HelperPickerView` loads assignees from `ContactRepository` (care group contacts) instead of hardcoded helpers
- `TaskSheetView` uses `CareContact` for assigned helpers, shared with Settings care group data
- Care Group section: Add Member opens Contacts picker in place; View All navigates to full list
- Details tab shows patient health profile (Grandma Marie) from `PatientRepository`
- Fixed double chevron on Care Group list rows
