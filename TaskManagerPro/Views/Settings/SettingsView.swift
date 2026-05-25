// MARK: - SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var auth: AuthService
    @StateObject private var viewModel = SettingsViewModel()

    @AppStorage("userName")           private var userName = ""
    @AppStorage("userRole")           private var userRole = ""
    @AppStorage("hasSeenOnboarding")  private var hasSeenOnboarding = false

    @State private var isEditingProfile = false
    @State private var isChangingPin    = false
    @State private var showLogoutAlert  = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {

                        Text("Settings")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .padding(.top, 8)

                        // ── ПРОФИЛЬ ──────────────────────────────────────
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeaderView(title: "Profile")

                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 60, height: 60)
                                    Text(String(userName.prefix(1).isEmpty ? "?" : userName.prefix(1)))
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                                .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(userName.isEmpty ? "Your Name" : userName)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                    Text(userRole.isEmpty ? "Tap to edit" : userRole)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Button { isEditingProfile = true } label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(Color.accentColor)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(18)
                        .glassCardStyle()

                        // ── ВНЕШНИЙ ВИД ───────────────────────────────────
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeaderView(title: "Appearance")
                            Picker("Theme", selection: $viewModel.appearance) {
                                ForEach(AppAppearance.allCases) { a in
                                    Text(a.title).tag(a)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(18)
                        .glassCardStyle()

                        // ── СОРТИРОВКА ─────────────────────────────────────
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeaderView(title: "Default Sorting")
                            Picker("Sort", selection: $viewModel.defaultSortOption) {
                                ForEach(TaskSortOption.allCases) { o in
                                    Text(o.title).tag(o)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(18)
                        .glassCardStyle()

                        // ── БЕЗОПАСНОСТЬ ───────────────────────────────────
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeaderView(title: "Security")

                            Button { isChangingPin = true } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: "lock.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(Color.accentColor)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(hasPinSet ? "Change PIN" : "Set PIN code")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                        Text(hasPinSet ? "Update your unlock PIN" : "Protect the app with a 4-digit PIN")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)

                            if hasPinSet {
                                Divider()
                                Button {
                                    UserDefaults.standard.set("", forKey: "appPin")
                                } label: {
                                    HStack(spacing: 14) {
                                        Image(systemName: "lock.open.fill")
                                            .font(.title2)
                                            .foregroundStyle(.orange)
                                        Text("Remove PIN")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.orange)
                                        Spacer()
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(18)
                        .glassCardStyle()

                        // ── АВТО-УДАЛЕНИЕ ──────────────────────────────────
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeaderView(title: "Auto-Clean")
                            HStack(spacing: 12) {
                                Image(systemName: "trash.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.red.opacity(0.8))
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Auto-delete completed")
                                        .font(.subheadline.weight(.semibold))
                                    Text("Completed tasks are automatically deleted after 1 day")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(18)
                        .glassCardStyle()

                        // ── ВЫХОД ──────────────────────────────────────────
                        Button { showLogoutAlert = true } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Log out & Reset")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .foregroundStyle(.red)
                            .padding(.vertical, 16)
                            .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, AppTheme.screenHorizontalPadding)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isEditingProfile) {
                ProfileEditSheet(userName: $userName, userRole: $userRole)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $isChangingPin) {
                NavigationStack {
                    ZStack {
                        AppBackgroundView()
                        SetPinView(onDone: { isChangingPin = false })
                    }
                    .navigationTitle("Set PIN")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") { isChangingPin = false }
                        }
                    }
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .alert("Log out?", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log out", role: .destructive) { logout() }
            } message: {
                Text("This will reset your profile and onboarding. Your tasks will remain.")
            }
        }
    }

    private var hasPinSet: Bool {
        let pin = UserDefaults.standard.string(forKey: "appPin") ?? ""
        return !pin.isEmpty
    }

    private func logout() {
        UserDefaults.standard.set("", forKey: "appPin")
        userName = ""
        userRole = ""
        hasSeenOnboarding = false
        auth.signOut()
    }
}

// MARK: - Шит редактирования профиля
struct ProfileEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var userName: String
    @Binding var userRole: String

    @State private var tempName = ""
    @State private var tempRole = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 90, height: 90)
                        Text(String(tempName.prefix(1).isEmpty ? "?" : tempName.prefix(1)))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: .blue.opacity(0.3), radius: 12, y: 6)
                    .padding(.top, 20)
                    .animation(.spring(response: 0.3), value: tempName)

                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("NAME").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                            TextField("Your name", text: $tempName)
                                .font(.system(size: 17, weight: .medium))
                                .padding(14)
                                .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("ROLE").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                            TextField("iOS Developer", text: $tempRole)
                                .font(.system(size: 17, weight: .medium))
                                .padding(14)
                                .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        userName = tempName.trimmingCharacters(in: .whitespaces)
                        userRole = tempRole.trimmingCharacters(in: .whitespaces)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(tempName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                tempName = userName
                tempRole = userRole
            }
        }
    }
}
