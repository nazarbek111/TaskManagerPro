// MARK: - TaskListView.swift
import SwiftUI
import SwiftData

struct TaskListView: View {

    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = TaskListViewModel()

    // Фильтруем таски только текущего пользователя
    @AppStorage("currentUserID") private var currentUserID = ""

    @Query(animation: .smooth) private var allTasks: [TaskItem]

    private var tasks: [TaskItem] {
        allTasks.filter { $0.ownerID == currentUserID }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AppBackgroundView()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 16) {
                            SearchBarView(text: $viewModel.searchText)
                                .padding(.top, 12)
                            QuoteCardView()

                            SortMenuView(selectedSortOption: $viewModel.selectedSortOption)

                            categoryBar

                            contentScrollBody
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 160)
                    }

                    Spacer(minLength: 0)
                }

                FloatingAddButton {
                    viewModel.prepareNewTask()
                }
                .padding(.trailing, 20)
                .padding(.bottom, 100)

                VStack(spacing: 0) {
                    Spacer()
                    bottomFilterBar
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.isPresentingEditor) {
                TaskEditorView(task: viewModel.selectedTaskForEditing)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                viewModel.autoDeleteOldCompletedTasks(from: tasks, context: modelContext)
            }
        }
    }

    // MARK: - Категории
    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TaskCategory.allCases) { category in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                            viewModel.selectedCategory = category
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: category.icon)
                                .font(.caption.weight(.semibold))
                            if category != .none {
                                Text(category.title)
                                    .font(.caption.weight(.semibold))
                            } else {
                                Text("Все")
                                    .font(.caption.weight(.semibold))
                            }
                        }
                        .foregroundStyle(viewModel.selectedCategory == category ? .white : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(
                                viewModel.selectedCategory == category
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

    // MARK: - Нижний бар
    private var bottomFilterBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.secondary.opacity(0.2))

            HStack(spacing: 0) {
                ForEach(TaskFilter.allCases) { filter in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                            viewModel.selectedFilter = filter
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(filter.title)
                                .font(.subheadline.weight(viewModel.selectedFilter == filter ? .bold : .regular))
                                .foregroundStyle(viewModel.selectedFilter == filter ? Color.accentColor : .secondary)

                            Capsule()
                                .fill(viewModel.selectedFilter == filter ? Color.accentColor : Color.clear)
                                .frame(width: 24, height: 3)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .background(.ultraThinMaterial)
            .padding(.bottom, 0)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Список задач
    private var contentScrollBody: some View {
        let items = viewModel.filteredAndSortedTasks(from: tasks)

        return Group {
            if items.isEmpty {
                EmptyStateView(
                    title: viewModel.searchText.isEmpty ? "No tasks yet" : "Nothing found",
                    subtitle: viewModel.searchText.isEmpty
                        ? "Create your first task and build momentum."
                        : "Try another keyword.",
                    systemImage: viewModel.searchText.isEmpty ? "tray.fill" : "magnifyingglass"
                )
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(items) { task in
                        TaskCardView(
                            task: task,
                            onComplete: {
                                viewModel.toggleCompletion(for: task, context: modelContext)
                            },
                            onEdit: {
                                viewModel.edit(task: task)
                            },
                            onPin: {
                                viewModel.togglePin(for: task, context: modelContext)
                            },
                            onDelete: {
                                viewModel.delete(task: task, context: modelContext)
                            }
                        )
                    }
                }
            }
        }
    }
}
