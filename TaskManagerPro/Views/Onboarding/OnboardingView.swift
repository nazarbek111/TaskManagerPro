


import SwiftUI

// MARK: - Шаги онбординга
private enum OnboardingStep {
    case welcome      // 3 слайда "Stay Organized" etc
    case createProfile // имя + роль
    case setPin       // 4-значный PIN
}

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var step: OnboardingStep = .welcome
    @State private var slideIndex = 0

    private let pages: [(String, String, String)] = [
        ("Stay Organized", "Capture tasks, deadlines, and priorities in one clean place.", "checklist.checked"),
        ("Move Faster",    "Use swipe actions, smart filters, and smooth editing flows.", "bolt.fill"),
        ("Hit Deadlines",  "Enable reminders and keep your momentum every day.",          "bell.badge.fill")
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.accentColor.opacity(0.16), Color(.systemBackground), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            switch step {
            case .welcome:
                welcomeView
                    .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .leading).combined(with: .opacity)))
            case .createProfile:
                CreateProfileView(onDone: { step = .setPin })
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
            case .setPin:
                SetPinView(onDone: { viewModel.finishOnboarding() })
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.88), value: step)
    }

    // MARK: - Слайды приветствия
    private var welcomeView: some View {
        VStack(spacing: 24) {
            Spacer()

            TabView(selection: $slideIndex) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    VStack(spacing: 20) {
                        Image(systemName: page.2)
                            .font(.system(size: 64, weight: .semibold))
                            .foregroundStyle(Color.accentColor)
                            .padding(30)
                            .background(.ultraThinMaterial, in: Circle())

                        Text(page.0)
                            .font(.system(size: 32, weight: .bold, design: .rounded))

                        Text(page.1)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 420)

            Button {
                if slideIndex < pages.count - 1 {
                    withAnimation { slideIndex += 1 }
                } else {
                    step = .createProfile
                }
            } label: {
                Text(slideIndex == pages.count - 1 ? "Get Started" : "Continue")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 24)
        }
    }
}

// MARK: - Создание профиля
struct CreateProfileView: View {
    let onDone: () -> Void

    @AppStorage("userName") private var userName = ""
    @AppStorage("userRole") private var userRole = ""

    @State private var name = ""
    @State private var role = ""
    @FocusState private var focusedField: Field?

    private enum Field { case name, role }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Аватар-превью
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 100, height: 100)
                Text(name.prefix(1).isEmpty ? "?" : String(name.prefix(1)))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .shadow(color: .blue.opacity(0.35), radius: 16, y: 8)
            .animation(.spring(response: 0.3), value: name)

            VStack(spacing: 8) {
                Text("Create your profile")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text("This will be shown on your home screen")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                // Имя
                VStack(alignment: .leading, spacing: 6) {
                    Text("YOUR NAME")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    TextField("e.g. Nazarbek", text: $name)
                        .font(.system(size: 17, weight: .medium))
                        .padding(16)
                        .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .role }
                }

                // Роль
                VStack(alignment: .leading, spacing: 6) {
                    Text("YOUR ROLE")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    TextField("e.g. iOS Developer", text: $role)
                        .font(.system(size: 17, weight: .medium))
                        .padding(16)
                        .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
                        .focused($focusedField, equals: .role)
                        .submitLabel(.done)
                        .onSubmit { saveAndContinue() }
                }
            }
            .padding(.horizontal, 24)

            Button(action: saveAndContinue) {
                Text("Continue")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        name.trimmingCharacters(in: .whitespaces).isEmpty
                            ? Color.secondary
                            : Color.accentColor,
                        in: RoundedRectangle(cornerRadius: 22, style: .continuous)
                    )
            }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.horizontal, 24)

            Spacer()
        }
        .onAppear { focusedField = .name }
    }

    private func saveAndContinue() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        userName = name.trimmingCharacters(in: .whitespaces)
        userRole = role.trimmingCharacters(in: .whitespaces)
        focusedField = nil
        onDone()
    }
}

// MARK: - Установка PIN-кода
struct SetPinView: View {
    let onDone: () -> Void

    @State private var pin = ""
    @State private var confirmPin = ""
    @State private var isConfirming = false
    @State private var errorMessage = ""
    @State private var shakeOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "lock.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color.accentColor)

            VStack(spacing: 8) {
                Text(isConfirming ? "Confirm PIN" : "Set a PIN code")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text(isConfirming ? "Enter your PIN again" : "You'll use it to unlock the app")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)

            // Точки PIN
            HStack(spacing: 20) {
                ForEach(0..<4, id: \.self) { index in
                    let currentPin = isConfirming ? confirmPin : pin
                    Circle()
                        .fill(index < currentPin.count ? Color.accentColor : Color.secondary.opacity(0.25))
                        .frame(width: 18, height: 18)
                        .scaleEffect(index < currentPin.count ? 1.15 : 1.0)
                        .animation(.spring(response: 0.2), value: currentPin.count)
                }
            }
            .offset(x: shakeOffset)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.red)
                    .transition(.opacity)
            }

            // Цифровая клавиатура
            pinKeypad

            // Пропустить
            Button("Skip") {
                UserDefaults.standard.set("", forKey: "appPin")
                onDone()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Spacer(minLength: 24)
        }
        .animation(.spring(response: 0.3), value: errorMessage)
    }

    private var pinKeypad: some View {
        let keys = ["1","2","3","4","5","6","7","8","9","","0","⌫"]
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
            ForEach(keys, id: \.self) { key in
                if key.isEmpty {
                    Color.clear.frame(height: 72)
                } else {
                    Button {
                        keyTapped(key)
                    } label: {
                        Text(key)
                            .font(.system(size: key == "⌫" ? 22 : 26, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 72)
                            .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 40)
    }

    private func keyTapped(_ key: String) {
        var current = isConfirming ? confirmPin : pin

        if key == "⌫" {
            if !current.isEmpty { current.removeLast() }
        } else {
            if current.count < 4 { current.append(key) }
        }

        if isConfirming {
            confirmPin = current
            if confirmPin.count == 4 { checkPins() }
        } else {
            pin = current
            if pin.count == 4 {
                withAnimation { isConfirming = true }
            }
        }
    }

    private func checkPins() {
        if pin == confirmPin {
            UserDefaults.standard.set(pin, forKey: "appPin")
            onDone()
        } else {
            errorMessage = "PINs don't match. Try again."
            confirmPin = ""
            pin = ""
            isConfirming = false
            // Shake animation
            withAnimation(.default) { shakeOffset = 10 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.default) { shakeOffset = -10 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.default) { shakeOffset = 0 }
                }
            }
        }
    }
}
