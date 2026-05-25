// MARK: - TaskEditorViewModel.swift

import Foundation
import SwiftData
import Combine
import UIKit

final class TaskEditorViewModel: ObservableObject {
    @Published var title: String
    @Published var description: String
    @Published var priority: TaskPriority
    @Published var hasDeadline: Bool
    @Published var deadline: Date
    @Published var isPinned: Bool
    @Published var category: TaskCategory

    let editingTask: TaskItem?

    private let notificationService: NotificationServiceProtocol
    private let hapticService: HapticServiceProtocol

    var isEditing: Bool { editingTask != nil }

    var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(task: TaskItem? = nil, container: AppContainer = .shared) {
        self.editingTask = task
        self.notificationService = container.notificationService
        self.hapticService = container.hapticService
        self.title = task?.title ?? ""
        self.description = task?.taskDescription ?? ""
        self.priority = task?.priority ?? .medium
        self.hasDeadline = task?.deadline != nil
        self.deadline = task?.deadline ?? Calendar.current.date(byAdding: .hour, value: 2, to: .now) ?? .now
        self.isPinned = task?.isPinned ?? false
        self.category = task?.category ?? .none
    }

    func save(context: ModelContext) {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalDeadline = hasDeadline ? deadline : nil
        // Берём текущего пользователя
        let ownerID = UserDefaults.standard.string(forKey: "currentUserID") ?? ""

        if let editingTask {
            editingTask.title = cleanTitle
            editingTask.taskDescription = cleanDescription
            editingTask.priority = priority
            editingTask.deadline = finalDeadline
            editingTask.isPinned = isPinned
            editingTask.category = category

            notificationService.removeNotification(for: editingTask)
            if finalDeadline != nil {
                notificationService.scheduleNotification(for: editingTask)
            }
        } else {
            let task = TaskItem(
                title: cleanTitle,
                taskDescription: cleanDescription,
                deadline: finalDeadline,
                isCompleted: false,
                isPinned: isPinned,
                priority: priority,
                category: category,
                ownerID: ownerID   // Привязываем к текущему пользователю
            )

            context.insert(task)

            if finalDeadline != nil {
                notificationService.scheduleNotification(for: task)
            }
        }

        try? context.save()
        hapticService.notify(UINotificationFeedbackGenerator.FeedbackType.success)
    }
}
