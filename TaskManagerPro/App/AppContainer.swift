//
//  AppContainer.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 19.03.2026.
//

import Foundation

final class AppContainer {
    static let shared = AppContainer()

    let notificationService: NotificationServiceProtocol
    let hapticService: HapticServiceProtocol
    let settingsService: SettingsServiceProtocol

    private init(
        notificationService: NotificationServiceProtocol = NotificationService(),
        hapticService: HapticServiceProtocol = HapticService(),
        settingsService: SettingsServiceProtocol = SettingsService()
    ) {
        self.notificationService = notificationService
        self.hapticService = hapticService
        self.settingsService = settingsService
    }
}

