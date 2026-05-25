

import SwiftUI

struct LockScreenView: View {
    let onUnlocked: () -> Void

    @AppStorage("userName") private var userName = ""
    @AppStorage("userRole") private var userRole = ""

    @State private var enteredPin = ""
    @State private var errorMessage = ""
    @State private var shakeOffset: CGFloat = 0
    @State private var attempts = 0

    private var savedPin: String {
        UserDefaults.standard.string(forKey: "appPin") ?? ""
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.accentColor.opacity(0.18), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Аватар + имя
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 90, height: 90)
                        Text(String(userName.prefix(1).isEmpty ? "?" : userName.prefix(1)))
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: .blue.opacity(0.35), radius: 14, y: 7)

                    Text(userName.isEmpty ? "Welcome back" : "Welcome back, \(userName.components(separatedBy: " ").first ?? userName)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))

                    if !userRole.isEmpty {
                        Text(userRole)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // Иконка замка
                Image(systemName: "lock.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.accentColor)

                // Точки PIN
                HStack(spacing: 20) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(index < enteredPin.count ? Color.accentColor : Color.secondary.opacity(0.25))
                            .frame(width: 18, height: 18)
                            .scaleEffect(index < enteredPin.count ? 1.15 : 1.0)
                            .animation(.spring(response: 0.2), value: enteredPin.count)
                    }
                }
                .offset(x: shakeOffset)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }

                // Клавиатура
                pinKeypad

                Spacer(minLength: 24)
            }
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
        if key == "⌫" {
            if !enteredPin.isEmpty { enteredPin.removeLast() }
            return
        }
        guard enteredPin.count < 4 else { return }
        enteredPin.append(key)

        if enteredPin.count == 4 {
            checkPin()
        }
    }

    private func checkPin() {
        if enteredPin == savedPin {
            onUnlocked()
        } else {
            attempts += 1
            errorMessage = attempts >= 3
                ? "Wrong PIN. Attempts: \(attempts)"
                : "Wrong PIN. Try again."
            enteredPin = ""
            // Shake
            withAnimation { shakeOffset = 10 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation { shakeOffset = -10 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    withAnimation { shakeOffset = 0 }
                }
            }
        }
    }
}
