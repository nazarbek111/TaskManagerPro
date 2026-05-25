// MARK: - AuthView.swift
// Экран входа и регистрации

import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var auth: AuthService
    @State private var mode: AuthMode = .login
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @FocusState private var focused: Field?

    enum AuthMode { case login, register }
    enum Field { case name, email, password, confirmPassword }

    var body: some View {
        ZStack {
            // Фон
            LinearGradient(
                colors: [Color.accentColor.opacity(0.18), Color(.systemBackground), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Лого
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(Color.accentColor)
                            .padding(24)
                            .background(.ultraThinMaterial, in: Circle())
                            .shadow(color: .accentColor.opacity(0.3), radius: 16, y: 8)

                        Text("TaskManager Pro")
                            .font(.system(size: 28, weight: .bold, design: .rounded))

                        Text(mode == .login ? "Войдите в свой аккаунт" : "Создайте новый аккаунт")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 40)

                    // Переключатель режима
                    modeSwitcher
                        .padding(.horizontal, 24)
                        .padding(.bottom, 28)

                    // Поля
                    VStack(spacing: 16) {
                        if mode == .register {
                            inputField(
                                label: "ИМЯ",
                                placeholder: "Например: Назарбек",
                                text: $name,
                                field: .name,
                                icon: "person.fill"
                            )
                        }

                        inputField(
                            label: "EMAIL",
                            placeholder: "example@mail.com",
                            text: $email,
                            field: .email,
                            icon: "envelope.fill",
                            keyboard: .emailAddress
                        )

                        passwordField(
                            label: "ПАРОЛЬ",
                            placeholder: mode == .login ? "Ваш пароль" : "Придумайте пароль",
                            text: $password,
                            show: $showPassword,
                            field: .password
                        )

                        // Критерии пароля при регистрации
                        if mode == .register && !password.isEmpty {
                            passwordCriteriaView
                        }

                        if mode == .register {
                            passwordField(
                                label: "ПОДТВЕРЖДЕНИЕ ПАРОЛЯ",
                                placeholder: "Повторите пароль",
                                text: $confirmPassword,
                                show: $showConfirmPassword,
                                field: .confirmPassword
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    // Ошибка
                    if !errorMessage.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(errorMessage)
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(.red)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Кнопка действия
                    Button(action: performAction) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.accentColor)

                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(mode == .login ? "Войти" : "Зарегистрироваться")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(height: 56)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 24)
                    .padding(.top, 28)

                    Spacer(minLength: 40)
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: mode)
        .animation(.spring(response: 0.3), value: errorMessage)
    }

    // MARK: - Переключатель Login / Register
    private var modeSwitcher: some View {
        HStack(spacing: 0) {
            ForEach([AuthMode.login, .register], id: \.self) { m in
                Button {
                    withAnimation {
                        mode = m
                        errorMessage = ""
                        password = ""
                        confirmPassword = ""
                    }
                } label: {
                    Text(m == .login ? "Вход" : "Регистрация")
                        .font(.subheadline.weight(mode == m ? .bold : .regular))
                        .foregroundStyle(mode == m ? Color.accentColor : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            mode == m
                            ? Color.accentColor.opacity(0.12)
                            : Color.clear,
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Поле ввода
    private func inputField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        field: Field,
        icon: String,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                TextField(placeholder, text: text)
                    .font(.system(size: 16, weight: .medium))
                    .keyboardType(keyboard)
                    .autocapitalization(keyboard == .emailAddress ? .none : .words)
                    .autocorrectionDisabled()
                    .focused($focused, equals: field)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.secondary.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(focused == field ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1.5)
                    )
            )
        }
    }

    // MARK: - Поле пароля
    private func passwordField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        show: Binding<Bool>,
        field: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                Group {
                    if show.wrappedValue {
                        TextField(placeholder, text: text)
                    } else {
                        SecureField(placeholder, text: text)
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .focused($focused, equals: field)

                Button {
                    show.wrappedValue.toggle()
                } label: {
                    Image(systemName: show.wrappedValue ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.secondary.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(focused == field ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1.5)
                    )
            )
        }
    }

    // MARK: - Критерии пароля
    private var passwordCriteriaView: some View {
        let criteria = auth.passwordCriteria(for: password)
        return VStack(alignment: .leading, spacing: 6) {
            ForEach(criteria, id: \.text) { c in
                HStack(spacing: 8) {
                    Image(systemName: c.isMet ? "checkmark.circle.fill" : "circle")
                        .font(.caption)
                        .foregroundStyle(c.isMet ? .green : .secondary)
                    Text(c.text)
                        .font(.caption)
                        .foregroundStyle(c.isMet ? .primary : .secondary)
                }
            }
        }
        .padding(.horizontal, 4)
        .animation(.easeInOut(duration: 0.2), value: password)
    }

    // MARK: - Действие
    private func performAction() {
        focused = nil
        errorMessage = ""
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            do {
                if mode == .login {
                    try auth.signIn(email: email, password: password)
                } else {
                    guard password == confirmPassword else {
                        errorMessage = "Пароли не совпадают"
                        isLoading = false
                        return
                    }
                    try auth.register(name: name, email: email, password: password)
                }
                // Устанавливаем онбординг как пройденный
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
