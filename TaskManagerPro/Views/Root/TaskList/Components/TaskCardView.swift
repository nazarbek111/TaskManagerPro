//
//  TaskCardView.swift
//  TaskManagerPro
//

import SwiftUI

struct TaskCardView: View {
    let task: TaskItem
    let onComplete: () -> Void
    let onEdit: () -> Void
    let onPin: () -> Void
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var isDragging = false

    private let swipeThreshold: CGFloat = 80

    var body: some View {
        ZStack {
            // MARK: - Фоновые индикаторы свайпа
            HStack {
                // Левый фон — ПИН (свайп влево → показывается слева? нет — свайп влево = offset < 0)
                // Свайп вправо (offset > 0) = УДАЛИТЬ (красный, слева)
                HStack(spacing: 8) {
                    Image(systemName: "trash.fill")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                    Text("Удалить")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 20)
                .background(Color.red.opacity(offset > 0 ? min(offset / swipeThreshold, 1.0) : 0))
                .cornerRadius(18)
                .opacity(offset > 20 ? 1 : 0)

                Spacer()

                // Правый фон — ПИН (свайп влево = offset < 0)
                HStack(spacing: 8) {
                    Text(task.isPinned ? "Открепить" : "Закрепить")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Image(systemName: task.isPinned ? "pin.slash.fill" : "pin.fill")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                }
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 20)
                .background(Color.orange.opacity(offset < 0 ? min(-offset / swipeThreshold, 1.0) : 0))
                .cornerRadius(18)
                .opacity(offset < -20 ? 1 : 0)
            }

            // MARK: - Карточка задачи
            cardContent
                .offset(x: offset)
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onChanged { value in
                            let translation = value.translation.width
                            // Добавляем сопротивление при большом свайпе
                            withAnimation(.interactiveSpring()) {
                                offset = translation * 0.75
                            }
                            isDragging = true
                        }
                        .onEnded { value in
                            isDragging = false
                            let translation = value.translation.width

                            if translation > swipeThreshold {
                                // Свайп вправо → УДАЛИТЬ
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    offset = UIScreen.main.bounds.width
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onDelete()
                                }
                            } else if translation < -swipeThreshold {
                                // Свайп влево → ПИН/ОТКРЕПИТЬ
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    offset = 0
                                }
                                onPin()
                            } else {
                                // Возврат на место
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                    offset = 0
                                }
                            }
                        }
                )
        }
        .clipped()
    }

    // MARK: - Содержимое карточки
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Button(action: onComplete) {
                    ZStack {
                        Circle()
                            .strokeBorder(
                                task.isCompleted ? Color.green : Color.secondary.opacity(0.25),
                                lineWidth: 2
                            )
                            .frame(width: 26, height: 26)

                        if task.isCompleted {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 26, height: 26)

                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(task.title)
                            .font(.headline)
                            .foregroundStyle(task.isCompleted ? .secondary : .primary)
                            .strikethrough(task.isCompleted, color: .secondary)
                            .lineLimit(2)

                        if task.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                                .transition(.scale)
                        }
                    }

                    if !task.taskDescription.isEmpty {
                        Text(task.taskDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                priorityBadge

                if let deadline = task.deadline {
                    Label(deadline.formattedShort, systemImage: "calendar")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.secondary.opacity(0.12), in: Capsule())
                }

                Spacer()
            }
        }
        .padding(18)
        .glassCardStyle()
        .scaleEffect(task.isCompleted ? 0.985 : 1)
        .opacity(task.isCompleted ? 0.84 : 1)
        .contextMenu {
            Button(task.isCompleted ? "Mark as Active" : "Mark Completed", action: onComplete)
            Button("Edit", action: onEdit)
            Button(task.isPinned ? "Unpin" : "Pin", action: onPin)
            Divider()
            Button(role: .destructive) { onDelete() } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
        .onTapGesture {
            if abs(offset) < 5 {
                onEdit()
            }
        }
    }

    private var priorityBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(task.priority.color)
                .frame(width: 8, height: 8)

            Text(task.priority.title)
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(task.priority.color.opacity(0.14), in: Capsule())
    }
}
