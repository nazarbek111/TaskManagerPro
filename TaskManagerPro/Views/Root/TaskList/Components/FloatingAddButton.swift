//
//  FloatingAddButton.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 19.03.2026.
//


import SwiftUI

struct FloatingAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: AppTheme.fabSize, height: AppTheme.fabSize)
                .background(
                    LinearGradient(
                        colors: [.accentColor, .accentColor.opacity(0.82)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: .accentColor.opacity(0.35), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .scaleOnPress()
    }
}
