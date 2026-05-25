//
//  UIKitTaskTableViewModel.swift
//  TaskManagerPro
//

import Foundation

final class UIKitTaskTableViewModel {
    enum Section: Int, CaseIterable {
        case active = 0
        case completed = 1

        var title: String {
            switch self {
            case .active: return "Active Tasks"
            case .completed: return "Completed Tasks"
            }
        }
    }

    private(set) var all: [UIKitTaskRow] = []
    private(set) var filtered: [UIKitTaskRow] = []
    var isFiltering: Bool { !searchText.trimmingCharacters(in: .whitespaces).isEmpty }
    private(set) var searchText: String = "" {
        didSet { applyFilter() }
    }

    init(tasks: [UIKitTaskRow] = []) {
        self.all = tasks
        self.filtered = tasks
    }

    func update(tasks: [UIKitTaskRow]) {
        self.all = tasks
        applyFilter()
    }

    func setSearchText(_ text: String) {
        self.searchText = text
    }

    private func applyFilter() {
        let base = all
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            filtered = base
        } else {
            filtered = base.filter { $0.title.localizedCaseInsensitiveContains(trimmed) }
        }
    }

    func items(in section: Section) -> [UIKitTaskRow] {
        let source = filtered
        switch section {
        case .active:
            return source.filter { !$0.isCompleted }
        case .completed:
            return source.filter { $0.isCompleted }
        }
    }

    func deleteItem(at indexPath: IndexPath) -> UIKitTaskRow? {
        guard let section = Section(rawValue: indexPath.section) else { return nil }
        let item = items(in: section)[safe: indexPath.row]
        guard let toDelete = item else { return nil }
        all.removeAll { $0.id == toDelete.id }
        applyFilter()
        return toDelete
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
