//
//  NotificationService.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 19.03.2026.
//

import Foundation
import UserNotifications

protocol NotificationServiceProtocol {
    func requestAuthorization() async
    func scheduleNotification(for task: TaskItem)
    func removeNotification(for task: TaskItem)
}

final class NotificationService: NotificationServiceProtocol {
    func requestAuthorization() async {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("Notification authorization failed: \(error)")
        }
    }

    func scheduleNotification(for task: TaskItem) {
        guard let deadline = task.deadline, deadline > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body = "Deadline is coming up. Stay on track."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: deadline)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func removeNotification(for task: TaskItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
}

