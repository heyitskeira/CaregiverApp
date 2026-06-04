//
//  RegisterView.swift
//  CaregiverApp
//
//  Created by Dzikry Aji Santoso on 04/06/26.
//

import SwiftUI

struct SignUpView: View {
    @Binding var authMode: AuthMode
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var password: String = ""
    @State private var passwordConfirm: String = ""
    @State private var showPassword: Bool = false
    @State private var showPasswordConfirm: Bool = false

    var body: some View {
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
                HStack(spacing: 16) {
                    Image(systemName: "person.fill")
                        .foregroundColor(.accentColor)
                        .frame(width: 22)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                }
                .frame(height: 22)
                .padding(10)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.gray, lineWidth: 1)
                )

                HStack(spacing: 16) {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.accentColor)
                        .frame(width: 22)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                .frame(height: 22)
                .padding(10)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.gray, lineWidth: 1)
                )

                HStack(spacing: 16) {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.accentColor)
                        .frame(width: 22)
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                        .autocapitalization(.none)
                }
                .frame(height: 22)
                .padding(10)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.gray, lineWidth: 1)
                )

                HStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.accentColor)
                        .frame(width: 22)
                    if showPassword {
                        SecureField("Password", text: $password)
                            .frame(maxWidth: .infinity)
                    } else {
                        TextField("Password", text: $password)
                            .frame(maxWidth: .infinity)
                    }
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(
                            systemName: showPassword
                                ? "eye.slash.fill" : "eye.fill"
                        )
                        .foregroundColor(.gray)
                        .frame(width: 22)
                    }
                }
                .frame(height: 22)
                .padding(10)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.gray, lineWidth: 1)
                )

                HStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.accentColor)
                        .frame(width: 22)
                    if showPasswordConfirm {
                        SecureField(
                            "Password Confirmation",
                            text: $passwordConfirm
                        )
                    } else {
                        TextField(
                            "Password Confirmation",
                            text: $passwordConfirm
                        )
                    }
                    Button(action: {
                        showPasswordConfirm.toggle()
                    }) {
                        Image(
                            systemName: showPasswordConfirm
                                ? "eye.slash.fill" : "eye.fill"
                        )
                        .foregroundColor(.gray)
                        .frame(width: 22)
                    }

                }
                .frame(height: 22)
                .padding(10)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.gray, lineWidth: 1)
                )

            }
            .padding(.vertical, 24)

            Button(action: {
                // Handle sign in or sign up
            }) {
                Text("Create Account")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }

            HStack(alignment: .center, spacing: 8) {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .opacity(0.2)
                Text("or")
                    .opacity(0.6)
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .opacity(0.2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)

            Button(action: {
                // Apple sign in
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "apple.logo")
                    Text("Sign in with Apple")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }

            HStack {
                Text("Already have an account?")
                Button(action: {
                    authMode = .signIn
                }) {
                    Text("Sign in").bold().foregroundColor(.accent)
                }
            }
            .padding()

            Spacer()

        }.padding()
    }
}
