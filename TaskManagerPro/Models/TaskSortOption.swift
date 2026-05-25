//
//  TaskSortOption.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 19.03.2026.
//

import Foundation

enum TaskSortOption: String, CaseIterable, Identifiable {
    case dateCreated
    case deadline
    case priority
    case title

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dateCreated: return "Date Created"
        case .deadline: return "Deadline"
        case .priority: return "Priority"
        case .title: return "Title"
        }
    }
}

