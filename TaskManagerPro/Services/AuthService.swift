import Foundation
import Combine
import UIKit

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published private(set) var isLoggedIn: Bool = false
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var isLoading: Bool = false

    private let userDefaultsUserIDKey = "currentUserID"

    private init() {
        #if canImport(FirebaseAuth)
        setupAuthStateListener()
        #else
        self.isLoggedIn = false
        #endif
    }

    // MARK: - Register with Email/Password

    func register(email: String, password: String, completion: @escaping (Bool) -> Void) {
        #if canImport(FirebaseAuth)
        isLoading = true
        errorMessage = nil

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                guard let self else { return }

                self.isLoading = false

                if let error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }

                guard let user = authResult?.user else {
                    self.errorMessage = "Unexpected error: No user found after registration."
                    completion(false)
                    return
                }

                UserDefaults.standard.set(user.uid, forKey: self.userDefaultsUserIDKey)
                self.isLoggedIn = true
                completion(true)
            }
        }
        #else
        errorMessage = "Registration is unavailable because FirebaseAuth is not imported."
        completion(false)
        #endif
    }

    // MARK: - Login with Email/Password

    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        #if canImport(FirebaseAuth)
        isLoading = true
        errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                guard let self else { return }

                self.isLoading = false

                if let error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }

                guard let user = authResult?.user else {
                    self.errorMessage = "Unexpected error: No user found after login."
                    completion(false)
                    return
                }

                UserDefaults.standard.set(user.uid, forKey: self.userDefaultsUserIDKey)
                self.isLoggedIn = true
                completion(true)
            }
        }
        #else
        errorMessage = "Login is unavailable because FirebaseAuth is not imported."
        completion(false)
        #endif
    }

    // MARK: - Google Sign-In

    func signInWithGoogle(presentingViewController: UIViewController, completion: @escaping (Bool) -> Void) {
        #if canImport(FirebaseAuth) && canImport(FirebaseCore) && canImport(GoogleSignIn)
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Missing Google client ID."
            completion(false)
            return
        }

        isLoading = true
        errorMessage = nil

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            if let error {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "Failed to retrieve Google authentication tokens."
                    completion(false)
                }
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                DispatchQueue.main.async {
                    guard let self else { return }

                    self.isLoading = false

                    if let error {
                        self.errorMessage = error.localizedDescription
                        completion(false)
                        return
                    }

                    guard let firebaseUser = authResult?.user else {
                        self.errorMessage = "Unexpected error: No user after Google sign-in."
                        completion(false)
                        return
                    }

                    UserDefaults.standard.set(firebaseUser.uid, forKey: self.userDefaultsUserIDKey)
                    self.isLoggedIn = true
                    completion(true)
                }
            }
        }
        #else
        errorMessage = "Google Sign-In is unavailable because FirebaseAuth, FirebaseCore, or GoogleSignIn is not imported."
        completion(false)
        #endif
    }

    // MARK: - Sign Out

    func signOut(completion: @escaping (Bool) -> Void) {
        #if canImport(FirebaseAuth)
        do {
            try Auth.auth().signOut()

            #if canImport(GoogleSignIn)
            GIDSignIn.sharedInstance.signOut()
            #endif

            UserDefaults.standard.removeObject(forKey: userDefaultsUserIDKey)
            isLoggedIn = false
            completion(true)
        } catch {
            errorMessage = error.localizedDescription
            completion(false)
        }
        #else
        errorMessage = "Sign out is unavailable because FirebaseAuth is not imported."
        completion(false)
        #endif
    }

    // MARK: - Helpers for SwiftUI

    func clearError() {
        errorMessage = nil
    }

    // MARK: - Private Methods

    #if canImport(FirebaseAuth)
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                guard let self else { return }

                if let user {
                    self.isLoggedIn = true
                    UserDefaults.standard.set(user.uid, forKey: self.userDefaultsUserIDKey)
                } else {
                    self.isLoggedIn = false
                    UserDefaults.standard.removeObject(forKey: self.userDefaultsUserIDKey)
                }
            }
        }
    }
    #endif
}
