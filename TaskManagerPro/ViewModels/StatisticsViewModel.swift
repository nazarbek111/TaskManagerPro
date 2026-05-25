//
//  StatisticsViewModel.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 19.03.2026.
//
import Foundation
import Combine

final class StatisticsViewModel: ObservableObject {
    init() {}

    func totalTasks(from tasks: [TaskItem]) -> Int {
        tasks.count
    }

    func completedTasks(from tasks: [TaskItem]) -> Int {
        tasks.filter { $0.isCompleted }.count
    }

    func activeTasks(from tasks: [TaskItem]) -> Int {
        tasks.filter { !$0.isCompleted }.count
    }

    func pinnedTasks(from tasks: [TaskItem]) -> Int {
        tasks.filter { $0.isPinned }.count
    }

    func completionRate(from tasks: [TaskItem]) -> Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedTasks(from: tasks)) / Double(tasks.count)
    }

    func highPriorityCount(from tasks: [TaskItem]) -> Int {
        tasks.filter { $0.priority == .high }.count
    }
}
