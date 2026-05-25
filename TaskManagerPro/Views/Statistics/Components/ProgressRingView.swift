//
//  ProgressRingView.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 19.03.2026.
//

import SwiftUI

struct ProgressRingView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.14), lineWidth: 14)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [Color.accentColor, .green, Color.accentColor],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.85), value: progress)

            VStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)

                Text("\(Int(progress * 100))%")
                    .font(.headline.weight(.bold))
            }
        }
    }
}
