// MARK: - TaskItem.swift

import Foundation
import SwiftData

// MARK: - Категории задач
enum TaskCategory: String, CaseIterable, Identifiable, Codable {
    case none       = "none"
    case home       = "home"
    case study      = "study"
    case work       = "work"
    case personal   = "personal"
    case sport      = "sport"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none:     return "All"
        case .home:     return "🏠 Дом"
        case .study:    return "📚 Учёба"
        case .work:     return "💼 Работа"
        case .personal: return "🙋 Личное"
        case .sport:    return "🏃 Спорт"
        }
    }

    var icon: String {
        switch self {
        case .none:     return "square.grid.2x2"
        case .home:     return "house.fill"
        case .study:    return "book.fill"
        case .work:     return "briefcase.fill"
        case .personal: return "person.fill"
        case .sport:    return "figure.run"
        }
    }

    var color: String {
        switch self {
        case .none:     return "blue"
        case .home:     return "orange"
        case .study:    return "purple"
        case .work:     return "blue"
        case .personal: return "green"
        case .sport:    return "red"
        }
    }
}

@Model
final class TaskItem {
    var id: UUID
    var title: String
    var taskDescription: String
    var createdAt: Date
    var deadline: Date?
    var isCompleted: Bool
    var isPinned: Bool
    var priorityRawValue: String
    var categoryRawValue: String
    var completedAt: Date?
    var ownerID: String /// ////////////

    init(
        id: UUID = UUID(),
        title: String,
        taskDescription: String = "",
        createdAt: Date = .now,
        deadline: Date? = nil,
        isCompleted: Bool = false,
        isPinned: Bool = false,
        priority: TaskPriority = .medium,
        category: TaskCategory = .none,
        ownerID: String = ""
    ) {
        self.id = id
        self.title = title
        self.taskDescription = taskDescription
        self.createdAt = createdAt
        self.deadline = deadline
        self.isCompleted = isCompleted
        self.isPinned = isPinned
        self.priorityRawValue = priority.rawValue
        self.categoryRawValue = category.rawValue
        self.completedAt = isCompleted ? .now : nil
        self.ownerID = ownerID
    }

    var priority: TaskPriority {
        get { TaskPriority(rawValue: priorityRawValue) ?? .medium }
        set { priorityRawValue = newValue.rawValue }
    }

    var category: TaskCategory {
        get { TaskCategory(rawValue: categoryRawValue) ?? .none }
        set { categoryRawValue = newValue.rawValue }
    }
}
