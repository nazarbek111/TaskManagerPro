//
//  UIKitTaskRow.swift
//  TaskManagerPro
//
//  Lightweight adapter for UIKit table view
//

import Foundation

struct UIKitTaskRow: Identifiable, Equatable {
    let id: UUID
    let title: String
    let isCompleted: Bool
    let priority: String
    let dueDate: Date?

    init(id: UUID, title: String, isCompleted: Bool, priority: String, dueDate: Date?) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
    }
}

extension UIKitTaskRow {
    static func from(task: TaskItem) -> UIKitTaskRow {
        UIKitTaskRow(
            id: task.id,
            title: task.title,
            isCompleted: task.isCompleted,
            priority: task.priority.rawValue,
            dueDate: task.deadline
        )
    }
}
