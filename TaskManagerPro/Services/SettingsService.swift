//
//  SettingsService.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 19.03.2026.
//

import Foundation

protocol SettingsServiceProtocol: AnyObject {
    var defaultSortOption: TaskSortOption { get set }
}

final class SettingsService: SettingsServiceProtocol {
    private let key = "defaultSortOption"

    var defaultSortOption: TaskSortOption {
        get {
            if let raw = UserDefaults.standard.string(forKey: key),
               let value = TaskSortOption(rawValue: raw) {
                return value
            }
            return .dateCreated
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
}
