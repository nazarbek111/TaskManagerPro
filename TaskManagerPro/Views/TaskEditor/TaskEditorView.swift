// MARK: - TaskEditorView.swift
import SwiftUI
import SwiftData

struct TaskEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: TaskEditorViewModel

    init(task: TaskItem? = nil) {
        _viewModel = StateObject(wrappedValue: TaskEditorViewModel(task: task))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        titleSection
                        categorySection   // НОВОЕ: выбор категории
                        detailsSection
                        optionsSection
                    }
                    .padding(.horizontal, AppTheme.screenHorizontalPadding)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        viewModel.save(context: modelContext)
                        dismiss()
                    }
                    .disabled(viewModel.isSaveDisabled)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Заголовок и описание
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Task")

            VStack(spacing: 14) {
                TextField("Title", text: $viewModel.title, axis: .vertical)
                    .font(.title3.weight(.semibold))

                Divider()

                TextField("Description", text: $viewModel.description, axis: .vertical)
                    .lineLimit(4...8)
                    .foregroundStyle(.secondary)
            }
            .padding(18)
            .glassCardStyle()
        }
    }

    // MARK: - Выбор категории (НОВЫЙ БЛОК)
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Category")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // Все категории кроме .none
                    ForEach(TaskCategory.allCases.filter { $0 != .none }) { category in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                                // Если нажали на уже выбранную — снимаем выбор
                                viewModel.category = viewModel.category == category ? .none : category
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .font(.caption.weight(.bold))
                                Text(category.title)
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundStyle(viewModel.category == category ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Capsule().fill(
                                    viewModel.category == category
                                        ? Color.accentColor
                                        : Color.secondary.opacity(0.12)
                                )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - Приоритет
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Priority")

            HStack(spacing: 12) {
                ForEach(TaskPriority.allCases) { priority in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                            viewModel.priority = priority
                        }
                    } label: {
                        Text(priority.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(viewModel.priority == priority ? .white : priority.color)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(
                                        viewModel.priority == priority
                                            ? priority.color
                                            : priority.color.opacity(0.14)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Опции (пин, дедлайн)
    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Options")

            VStack(spacing: 16) {
                Toggle("Pin task", isOn: $viewModel.isPinned)

                Toggle("Set deadline", isOn: $viewModel.hasDeadline.animation(.smooth))

                if viewModel.hasDeadline {
                    DatePicker(
                        "Deadline",
                        selection: $viewModel.deadline,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(18)
            .glassCardStyle()
        }
    }
}

