import SwiftUI
import UIKit

struct AuthView: View {
    @EnvironmentObject private var auth: AuthService

    @State private var isLoginMode: Bool = true
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var localError: String = ""

    @FocusState private var focusedField: Field?

    private enum Field {
        case email
        case password
        case confirm
    }

    var body: some View {
        VStack(spacing: 24) {
            Picker("", selection: $isLoginMode) {
                Text("Login").tag(true)
                Text("Register").tag(false)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            .onChange(of: isLoginMode) { _, _ in
                resetErrors()
            }

            Group {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.secondary.opacity(0.1))
                    )
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .password
                    }

                SecureField("Password", text: $password)
                    .textContentType(isLoginMode ? .password : .newPassword)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.secondary.opacity(0.1))
                    )
                    .focused($focusedField, equals: .password)
                    .submitLabel(isLoginMode ? .go : .next)
                    .onSubmit {
                        if isLoginMode {
                            performLogin()
                        } else {
                            focusedField = .confirm
                        }
                    }

                if !isLoginMode {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.secondary.opacity(0.1))
                        )
                        .focused($focusedField, equals: .confirm)
                        .submitLabel(.go)
                        .onSubmit {
                            performRegister()
                        }
                }
            }
            .padding(.horizontal, 24)

            Button {
                if isLoginMode {
                    performLogin()
                } else {
                    performRegister()
                }
            } label: {
                HStack {
                    if auth.isLoading {
                        ProgressView()
                            .tint(.white)
                    }

                    Text(isLoginMode ? "Login" : "Create Account")
                        .font(.headline.weight(.bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(isPrimaryButtonDisabled ? Color.gray : Color.accentColor)
                )
                .padding(.horizontal, 24)
            }
            .disabled(isPrimaryButtonDisabled)

            HStack {
                line

                Text("or")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                line
            }
            .padding(.horizontal, 24)

            Button {
                performGoogleSignIn()
            } label: {
                Text("Continue with Google")
                    .font(.headline)
                    .foregroundColor(Color.accentColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.accentColor, lineWidth: 2)
                    )
                    .padding(.horizontal, 24)
            }
            .disabled(auth.isLoading)

            if !currentMessage.isEmpty {
                Text(currentMessage)
                    .foregroundColor(.red)
                    .font(.subheadline.weight(.medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
            }

            Spacer()
        }
        .padding(.top, 40)
    }

    private var line: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.3))
            .frame(height: 1)
    }

    private var currentMessage: String {
        if let serviceMessage = auth.errorMessage, !serviceMessage.isEmpty {
            return serviceMessage
        }

        return localError
    }

    private var isPrimaryButtonDisabled: Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if auth.isLoading {
            return true
        }

        if trimmedEmail.isEmpty || password.isEmpty {
            return true
        }

        if !isLoginMode && confirmPassword.isEmpty {
            return true
        }

        return false
    }

    private func performLogin() {
        focusedField = nil
        resetErrors()

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else {
            localError = "Email is required."
            return
        }

        guard !trimmedPassword.isEmpty else {
            localError = "Password is required."
            return
        }

        auth.login(email: trimmedEmail, password: trimmedPassword) { _ in }
    }

    private func performRegister() {
        focusedField = nil
        resetErrors()

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirm = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else {
            localError = "Email is required."
            return
        }

        guard !trimmedPassword.isEmpty else {
            localError = "Password is required."
            return
        }

        guard trimmedPassword == trimmedConfirm else {
            localError = "Passwords do not match."
            return
        }

        auth.register(email: trimmedEmail, password: trimmedPassword) { _ in }
    }

    private func performGoogleSignIn() {
        focusedField = nil
        resetErrors()

        guard let rootViewController = currentRootViewController() else {
            localError = "Cannot find root view controller."
            return
        }

        auth.signInWithGoogle(presentingViewController: rootViewController) { _ in }
    }

    private func resetErrors() {
        localError = ""
        auth.clearError()
    }

    private func currentRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }

        return scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
    }
}
