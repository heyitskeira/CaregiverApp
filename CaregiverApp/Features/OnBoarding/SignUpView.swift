//
//  SignUpView.swift
//  CaregiverApp
//

import SwiftUI

struct SignUpView: View {
    @Binding var authMode: AuthMode
    var onSuccess: () -> Void

    @Environment(SessionStore.self) private var session

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var password: String = ""
    @State private var passwordConfirm: String = ""
    @State private var showPassword: Bool = false
    @State private var showPasswordConfirm: Bool = false
    @State private var isLoading = false

    private var passwordsMatch: Bool { password == passwordConfirm || passwordConfirm.isEmpty }

    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 4) {
                    Text("Create your account")
                        .font(.largeTitle).bold()
                        .foregroundStyle(Color.accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Let's get you started.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title3)
                }.padding(.vertical, 12)

                VStack(spacing: 12) {
                    // Full Name
                    HStack(spacing: 16) {
                        Image(systemName: "person.fill")
                            .foregroundColor(.accentColor).frame(width: 22)
                        TextField("Full Name", text: $name)
                            .textContentType(.name)
                    }
                    .frame(height: 22).padding(10).cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray, lineWidth: 1))

                    // Email
                    HStack(spacing: 16) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.accentColor).frame(width: 22)
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .frame(height: 22).padding(10).cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray, lineWidth: 1))

                    // Phone
                    HStack(spacing: 16) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.accentColor).frame(width: 22)
                        TextField("Phone Number", text: $phone)
                            .keyboardType(.phonePad)
                    }
                    .frame(height: 22).padding(10).cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray, lineWidth: 1))

                    // Password
                    HStack(spacing: 16) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.accentColor).frame(width: 22)
                        if showPassword {
                            TextField("Password", text: $password).frame(maxWidth: .infinity)
                        } else {
                            SecureField("Password", text: $password).frame(maxWidth: .infinity)
                        }
                        Button { showPassword.toggle() } label: {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray).frame(width: 22)
                        }
                    }
                    .frame(height: 22).padding(10).cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray, lineWidth: 1))

                    // Confirm Password
                    HStack(spacing: 16) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.accentColor).frame(width: 22)
                        if showPasswordConfirm {
                            TextField("Password Confirmation", text: $passwordConfirm)
                        } else {
                            SecureField("Password Confirmation", text: $passwordConfirm)
                        }
                        Button { showPasswordConfirm.toggle() } label: {
                            Image(systemName: showPasswordConfirm ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray).frame(width: 22)
                        }
                    }
                    .frame(height: 22).padding(10).cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(!passwordsMatch ? Color.red : .gray, lineWidth: 1)
                    )

                    if !passwordsMatch {
                        Text("Passwords do not match.")
                            .font(.caption).foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical, 24)

                if let error = session.signUpError {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                }

                Button {
                    guard passwordsMatch else { return }
                    isLoading = true
                    Task {
                        await session.signUp(name: name, email: email, phone: phone, password: password)
                        isLoading = false
                        if session.isAuthenticated {
                            onSuccess()
                        }
                    }
                } label: {
                    Group {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Create Account").fontWeight(.medium)
                        }
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .disabled(isLoading || !passwordsMatch)

                HStack(alignment: .center, spacing: 8) {
                    Rectangle().frame(maxWidth: .infinity, maxHeight: 1).opacity(0.2)
                    Text("or").opacity(0.6)
                    Rectangle().frame(maxWidth: .infinity, maxHeight: 1).opacity(0.2)
                }
                .padding(.horizontal, 12).padding(.vertical, 16)

                Button {
                    Task {
                        await session.signUp(name: "Demo User", email: "demo@example.com", phone: "+1234567890", password: "demo123")
                        if session.isAuthenticated { onSuccess() }
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "apple.logo")
                        Text("Sign in with Apple").bold()
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }

                HStack {
                    Text("Already have an account?")
                    Button {
                        authMode = .signIn
                    } label: {
                        Text("Sign in").bold().foregroundColor(.accent)
                    }
                }
                .padding()

                Spacer()
            }.padding()
        }
    }
}
