// MARK: - TaskListViewModel.swift
import Foundation
import SwiftData
import SwiftUI
import Combine
import UIKit

final class TaskListViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedFilter: TaskFilter = .all
    @Published var selectedSortOption: TaskSortOption
    @Published var selectedCategory: TaskCategory = .none
    @Published var isPresentingEditor = false
    @Published var selectedTaskForEditing: TaskItem?

    private let notificationService: NotificationServiceProtocol
    private let hapticService: HapticServiceProtocol
    private var settingsService: SettingsServiceProtocol

    init(container: AppContainer = .shared) {
        self.notificationService = container.notificationService
        self.hapticService = container.hapticService
        self.settingsService = container.settingsService
        self.selectedSortOption = container.settingsService.defaultSortOption
    }

    func prepareNewTask() {
        selectedTaskForEditing = nil
        isPresentingEditor = true
        hapticService.impact(.soft)
    }

    func edit(task: TaskItem) {
        selectedTaskForEditing = task
        isPresentingEditor = true
        hapticService.selection()
    }

    func delete(task: TaskItem, context: ModelContext) {
        notificationService.removeNotification(for: task)
        context.delete(task)
        try? context.save()
        hapticService.notify(.warning)
    }

    func toggleCompletion(for task: TaskItem, context: ModelContext) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
            task.isCompleted.toggle()
            // Записываем когда задача была завершена
            task.completedAt = task.isCompleted ? .now : nil
        }
        try? context.save()
        hapticService.notify(task.isCompleted ? .success : .warning)
    }

    func togglePin(for task: TaskItem, context: ModelContext) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            task.isPinned.toggle()
        }
        try? context.save()
        hapticService.selection()
    }

    func saveSortPreference() {
        settingsService.defaultSortOption = selectedSortOption
    }

    func requestNotifications() async {
        await notificationService.requestAuthorization()
    }

    // MARK: - Авто-удаление завершённых задач через 1 день
    /// Вызывать при каждом открытии приложения (в .onAppear на TaskListView)
    func autoDeleteOldCompletedTasks(from tasks: [TaskItem], context: ModelContext) {
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now

        let toDelete = tasks.filter { task in
            guard task.isCompleted else { return false }
            // Если completedAt не установлен — используем createdAt как запасной вариант
            let completionDate = task.completedAt ?? task.createdAt
            return completionDate < oneDayAgo
        }

        for task in toDelete {
            notificationService.removeNotification(for: task)
            context.delete(task)
        }

        if !toDelete.isEmpty {
            try? context.save()
            hapticService.impact(.soft)
        }
    }

    // MARK: - Фильтрация и сортировка
    func filteredAndSortedTasks(from tasks: [TaskItem]) -> [TaskItem] {
        let filtered = tasks.filter { task in
            // Поиск
            let matchesSearch = searchText.isEmpty ||
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.taskDescription.localizedCaseInsensitiveContains(searchText)

            // Фильтр (All/Active/Completed)
            let matchesFilter: Bool
            switch selectedFilter {
            case .all:       matchesFilter = true
            case .active:    matchesFilter = !task.isCompleted
            case .completed: matchesFilter = task.isCompleted
            }

            // Фильтр по категории
            let matchesCategory: Bool
            if selectedCategory == .none {
                matchesCategory = true
            } else {
                matchesCategory = task.category == selectedCategory
            }

            return matchesSearch && matchesFilter && matchesCategory
        }

        return filtered.sorted(by: sortComparator)
    }

    private func sortComparator(lhs: TaskItem, rhs: TaskItem) -> Bool {
        if lhs.isPinned != rhs.isPinned {
            return lhs.isPinned && !rhs.isPinned
        }

        switch selectedSortOption {
        case .dateCreated:
            return lhs.createdAt > rhs.createdAt

        case .deadline:
            switch (lhs.deadline, rhs.deadline) {
            case let (l?, r?):   return l < r
            case (_?, nil):      return true
            case (nil, _?):      return false
            case (nil, nil):     return lhs.createdAt > rhs.createdAt
            }

        case .priority:
            if lhs.priority.orderValue != rhs.priority.orderValue {
                return lhs.priority.orderValue < rhs.priority.orderValue
            }
            return lhs.createdAt > rhs.createdAt

        case .title:
            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }
    }
}
