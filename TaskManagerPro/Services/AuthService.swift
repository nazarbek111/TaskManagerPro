// MARK: - AuthService.swift
// Локальная аутентификация через email + пароль (хранится в Keychain через UserDefaults для простоты)
// Для production — замените на Keychain или Firebase Auth

import Foundation
import SwiftUI
import Combine
import CryptoKit
import SwiftUI
import CryptoKit

// MARK: - Модель пользователя
struct AppUser: Codable {
    let id: String          // UUID строкой
    let email: String
    var name: String
    var passwordHash: String
}

// MARK: - Ошибки аутентификации
enum AuthError: LocalizedError {
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case weakPassword(String)
    case invalidEmail
    case emptyFields

    var errorDescription: String? {
        switch self {
        case .emailAlreadyInUse:   return "Этот email уже используется"
        case .userNotFound:        return "Пользователь не найден"
        case .wrongPassword:       return "Неверный пароль"
        case .weakPassword(let r): return r
        case .invalidEmail:        return "Введите корректный email"
        case .emptyFields:         return "Заполните все поля"
        }
    }
}

// MARK: - Критерии пароля
struct PasswordCriteria {
    let text: String
    let isMet: Bool
}

// MARK: - AuthService
final class AuthService: ObservableObject {

    static let shared = AuthService()

    @Published var currentUser: AppUser?
    @Published var isLoggedIn: Bool = false

    private let usersKey = "registeredUsers"
    private let currentUserIDKey = "currentUserID"

    init() {
        // Восстанавливаем сессию
        let savedID = UserDefaults.standard.string(forKey: currentUserIDKey) ?? ""
        if !savedID.isEmpty, let user = findUser(byID: savedID) {
            self.currentUser = user
            self.isLoggedIn = true
        }
    }

    // MARK: - Регистрация
    func register(name: String, email: String, password: String) throws {
        let trimName = name.trimmingCharacters(in: .whitespaces)
        let trimEmail = email.trimmingCharacters(in: .whitespaces).lowercased()
        let trimPass = password.trimmingCharacters(in: .whitespaces)

        guard !trimName.isEmpty && !trimEmail.isEmpty && !trimPass.isEmpty else {
            throw AuthError.emptyFields
        }
        guard isValidEmail(trimEmail) else {
            throw AuthError.invalidEmail
        }
        if let error = passwordStrengthError(trimPass) {
            throw AuthError.weakPassword(error)
        }

        var users = loadUsers()
        guard !users.contains(where: { $0.email == trimEmail }) else {
            throw AuthError.emailAlreadyInUse
        }

        let newUser = AppUser(
            id: UUID().uuidString,
            email: trimEmail,
            name: trimName,
            passwordHash: hash(trimPass)
        )
        users.append(newUser)
        saveUsers(users)
        login(user: newUser)
    }

    // MARK: - Вход
    func signIn(email: String, password: String) throws {
        let trimEmail = email.trimmingCharacters(in: .whitespaces).lowercased()
        let trimPass = password.trimmingCharacters(in: .whitespaces)

        guard !trimEmail.isEmpty && !trimPass.isEmpty else {
            throw AuthError.emptyFields
        }
        guard isValidEmail(trimEmail) else {
            throw AuthError.invalidEmail
        }

        let users = loadUsers()
        guard let user = users.first(where: { $0.email == trimEmail }) else {
            throw AuthError.userNotFound
        }
        guard user.passwordHash == hash(trimPass) else {
            throw AuthError.wrongPassword
        }

        login(user: user)
    }

    // MARK: - Выход
    func signOut() {
        currentUser = nil
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: currentUserIDKey)
        // Сбрасываем онбординг тоже
        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
    }

    // MARK: - Критерии пароля (для UI)
    func passwordCriteria(for password: String) -> [PasswordCriteria] {
        [
            PasswordCriteria(text: "Минимум 8 символов",          isMet: password.count >= 8),
            PasswordCriteria(text: "Хотя бы одна заглавная буква", isMet: password.contains(where: { $0.isUppercase })),
            PasswordCriteria(text: "Хотя бы одна цифра",           isMet: password.contains(where: { $0.isNumber })),
        ]
    }

    // MARK: - Приватные методы
    private func login(user: AppUser) {
        currentUser = user
        isLoggedIn = true
        UserDefaults.standard.set(user.id, forKey: currentUserIDKey)
        // Также сохраняем в AppStorage совместимый ключ
        UserDefaults.standard.set(user.id, forKey: "currentUserID")
        UserDefaults.standard.set(user.name, forKey: "userName")
    }

    private func findUser(byID id: String) -> AppUser? {
        loadUsers().first(where: { $0.id == id })
    }

    private func loadUsers() -> [AppUser] {
        guard let data = UserDefaults.standard.data(forKey: usersKey),
              let users = try? JSONDecoder().decode([AppUser].self, from: data) else {
            return []
        }
        return users
    }

    private func saveUsers(_ users: [AppUser]) {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }

    private func hash(_ password: String) -> String {
        let data = Data(password.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }

    private func passwordStrengthError(_ password: String) -> String? {
        if password.count < 8 { return "Пароль должен быть не менее 8 символов" }
        if !password.contains(where: { $0.isUppercase }) { return "Добавьте хотя бы одну заглавную букву" }
        if !password.contains(where: { $0.isNumber }) { return "Добавьте хотя бы одну цифру" }
        return nil
    }
}
