//
//  HapticService.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 19.03.2026.
//
import UIKit

protocol HapticServiceProtocol {
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle)
    func notify(_ type: UINotificationFeedbackGenerator.FeedbackType)
    func selection()
}

final class HapticService: HapticServiceProtocol {
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
