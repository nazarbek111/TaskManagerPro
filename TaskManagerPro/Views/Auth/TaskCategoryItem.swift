//
//  TaskCategoryItem.swift
//  TaskManagerPro
//

import Foundation

struct TaskCategoryItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let systemIcon: String
    let description: String
}
