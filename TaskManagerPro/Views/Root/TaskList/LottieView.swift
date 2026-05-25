// LottieView.swift
// TaskManagerPro
// Lightweight SwiftUI wrapper for Lottie animations (optional dependency)

import SwiftUI
#if canImport(Lottie)
import Lottie
#endif

struct LottieView: View {
    let name: String
    var loopMode: Int = 0
    var playOnAppear: Bool = true

    var body: some View {
        #if canImport(Lottie)
        LottieContainer(name: name, loopMode: loopMode, playOnAppear: playOnAppear)
        #else
        Color.clear
        #endif
    }
}

#if canImport(Lottie)
private struct LottieContainer: UIViewRepresentable {
    let name: String
    var loopMode: Int
    var playOnAppear: Bool

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name)
        view.contentMode = .scaleAspectFit
        view.loopMode = {
            switch loopMode {
            case 1: return .loop
            case 2: return .autoReverse
            default: return .playOnce
            }
        }()
        if playOnAppear { view.play() }
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) { }
}
#endif
