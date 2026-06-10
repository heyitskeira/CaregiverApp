//
//  SignInview.swift
//  CaregiverApp
//

import SwiftUI

struct SignInview: View {
    @Binding var authMode: AuthMode
    var onSuccess: () -> Void

    @Environment(SessionStore.self) private var session

    @State private var phone: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 100, height: 100)
                    .overlay(Text("Logo").foregroundColor(.white))

                VStack(spacing: 4) {
                    Text("Welcome back")
                        .font(.largeTitle).bold()
                        .foregroundStyle(Color.accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Sign in to your account.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title3)
                }.padding(.vertical, 12)

                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.accentColor).frame(width: 22)
                        TextField("Phone Number", text: $phone)
                            .keyboardType(.phonePad)
                            .autocapitalization(.none)
                    }
                    .frame(height: 22).padding(10).cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray, lineWidth: 1))

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

                    Button(action: {}) {
                        Text("Forgot Password?")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .padding(.vertical, 24)

                if let error = session.signInError {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                }

                Button {
                    isLoading = true
                    Task {
                        await session.signIn(phone: phone, password: password)
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
                            Text("Sign In").fontWeight(.medium)
                        }
                    }
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .disabled(isLoading)

                HStack(alignment: .center, spacing: 8) {
                    Rectangle().frame(maxWidth: .infinity, maxHeight: 1).opacity(0.2)
                    Text("or").opacity(0.6)
                    Rectangle().frame(maxWidth: .infinity, maxHeight: 1).opacity(0.2)
                }
                .padding(.horizontal, 12).padding(.vertical, 16)

                Button {
                    Task {
                        await session.signIn(phone: "demo", password: "demo")
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
                    Text("Don't have an account?")
                    Button {
                        authMode = .signUp
                    } label: {
                        Text("Create Account").bold().foregroundColor(.accent)
                    }
                }
                .padding()

                Spacer()
            }.padding()
        }
    }
}
