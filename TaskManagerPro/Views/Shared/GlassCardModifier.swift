//
//  GlassCardModifier.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 19.03.2026.
//

import SwiftUI

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
            )
            .shadow(color: AppTheme.cardShadow, radius: 18, x: 0, y: 10)
    }
}

extension View {
    func glassCardStyle() -> some View {
        modifier(GlassCardModifier())
    }
}

