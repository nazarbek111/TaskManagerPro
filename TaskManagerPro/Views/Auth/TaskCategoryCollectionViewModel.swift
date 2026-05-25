//
//  TaskCategoryCollectionViewModel.swift
//  TaskManagerPro
//

import Foundation

final class TaskCategoryCollectionViewModel {
    private(set) var items: [TaskCategoryItem] = []
    private(set) var counts: [String: Int] = [:]

    init(items: [TaskCategoryItem] = TaskCategoryCollectionViewModel.defaultItems(), counts: [String: Int] = [:]) {
        self.items = items
        self.counts = counts
    }

    static func defaultItems() -> [TaskCategoryItem] {
        [
            TaskCategoryItem(name: "Study",    systemIcon: "book.fill",       description: "Learning & exams"),
            TaskCategoryItem(name: "Work",     systemIcon: "briefcase.fill",  description: "Office & projects"),
            TaskCategoryItem(name: "Home",     systemIcon: "house.fill",      description: "Household"),
            TaskCategoryItem(name: "Personal", systemIcon: "person.fill",     description: "Self & health"),
            TaskCategoryItem(name: "Sport",    systemIcon: "figure.run",      description: "Training"),
            TaskCategoryItem(name: "Urgent",   systemIcon: "exclamationmark.triangle.fill", description: "High priority")
        ]
    }
}
