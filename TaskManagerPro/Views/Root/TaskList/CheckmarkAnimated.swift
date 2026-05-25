import SwiftUI

struct CheckmarkAnimated: View {
    @Binding var isCompleted: Bool
    @State private var fillProgress: CGFloat = 0
    @State private var checkScale: CGFloat = 0.6
    @State private var sparkOpacity: Double = 0
    @State private var sparkScale: CGFloat = 0.5

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(isCompleted ? Color.green : Color.gray.opacity(0.25), lineWidth: 2)
                .background(
                    Circle()
                        .fill(Color.green)
                        .scaleEffect(fillProgress)
                        .opacity(fillProgress > 0 ? 1 : 0)
                )

            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .scaleEffect(checkScale)
                .opacity(isCompleted ? 1 : 0)

            // Искорки
            ForEach(0..<4, id: \.self) { i in
                Circle()
                    .fill(Color.green.opacity(0.6))
                    .frame(width: 3, height: 3)
                    .offset(sparkOffset(index: i))
                    .opacity(sparkOpacity)
                    .scaleEffect(sparkScale)
            }
        }
        .frame(width: 24, height: 24)
        .onAppear { if isCompleted { fillProgress = 1; checkScale = 1 } }
        .onChange(of: isCompleted) { _, newValue in
            if newValue {
                // Виброотклик
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                
                withAnimation(.easeOut(duration: 0.2)) { fillProgress = 1 }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7).delay(0.1)) { checkScale = 1 }
                
                // Анимация искр
                sparkOpacity = 1
                sparkScale = 0.5
                withAnimation(.easeOut(duration: 0.4)) {
                    sparkScale = 1.5
                    sparkOpacity = 0
                }
            } else {
                withAnimation(.easeIn(duration: 0.2)) {
                    fillProgress = 0
                    checkScale = 0.6
                }
            }
        }
    }

    private func sparkOffset(index: Int) -> CGSize {
        let radius: CGFloat = 14
        let angle = CGFloat(index) * .pi / 2
        return CGSize(width: cos(angle) * radius, height: sin(angle) * radius)
    }
}
