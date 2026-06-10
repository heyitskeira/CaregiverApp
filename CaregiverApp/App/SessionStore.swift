import Foundation
import Observation

@Observable
@MainActor
final class SessionStore {
    private(set) var isAuthenticated = false
    private(set) var isSignedIn = false

    private(set) var currentUser: UserProfile = SeedData.primaryCaregiver
    private(set) var currentCareTeam: CareTeam = SeedData.careTeam
    // The CareContact ID linked to the signed-in user (drives "My Tasks" filter)
    private(set) var currentContactID: UUID = SeedData.lilyID

    var signInError: String?
    var signUpError: String?
    var careGroupError: String?

    func signIn(phone: String, password: String) async {
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPhone.isEmpty, !trimmedPassword.isEmpty else {
            signInError = "Please enter your phone number and password."
            return
        }
        signInError = nil
        currentUser = SeedData.primaryCaregiver
        currentCareTeam = SeedData.careTeam
        currentContactID = SeedData.lilyID
        isAuthenticated = true
    }

    func signUp(name: String, email: String, phone: String, password: String) async {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !trimmedEmail.isEmpty, !trimmedPhone.isEmpty,
              password.count >= 6 else {
            signUpError = "Please fill in all fields. Password must be at least 6 characters."
            return
        }
        signUpError = nil
        currentUser = UserProfile(
            id: SeedData.primaryCaregiverID,
            name: trimmedName,
            phone: trimmedPhone,
            email: trimmedEmail,
            role: .primaryCaregiver
        )
        currentCareTeam = SeedData.careTeam
        currentContactID = SeedData.lilyID
        isAuthenticated = true
    }

    /// Sets up care group data. Call `finishOnboarding()` after showing the success screen.
    func createCareGroup(patientName: String) async {
        let trimmed = patientName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            careGroupError = "Please enter the patient's name."
            return
        }
        careGroupError = nil
        currentCareTeam = CareTeam(
            id: SeedData.careTeamID,
            name: "\(trimmed)'s Care Team",
            primaryCaregiverID: currentUser.id
        )
    }

    /// Sets up care group from invite. Call `finishOnboarding()` after showing the success screen.
    func joinCareGroup(code: String) async {
        guard code.count == 6 else {
            careGroupError = "Please enter a valid 6-character code."
            return
        }
        careGroupError = nil
        currentCareTeam = SeedData.careTeam
        currentContactID = SeedData.lilyID
    }

    /// Transitions the app from onboarding into the main experience.
    func finishOnboarding() {
        isSignedIn = true
    }

    func signOut() {
        isAuthenticated = false
        isSignedIn = false
        signInError = nil
        signUpError = nil
        careGroupError = nil
        currentUser = SeedData.primaryCaregiver
        currentCareTeam = SeedData.careTeam
        currentContactID = SeedData.lilyID
    }
}
