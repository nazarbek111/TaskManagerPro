//
//  SettingsViewModel.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 19.03.2026.
//

import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var appearance: AppAppearance {
        didSet {
            UserDefaults.standard.set(appearance.rawValue, forKey: "appAppearance")
        }
    }

    @Published var defaultSortOption: TaskSortOption {
        didSet {
            settingsService.defaultSortOption = defaultSortOption
        }
    }

    private var settingsService: SettingsServiceProtocol

    init(container: AppContainer = .shared) {
        self.settingsService = container.settingsService
        let appearanceRawValue = UserDefaults.standard.string(forKey: "appAppearance") ?? AppAppearance.system.rawValue
        self.appearance = AppAppearance(rawValue: appearanceRawValue) ?? .system
        self.defaultSortOption = container.settingsService.defaultSortOption
    }
}

