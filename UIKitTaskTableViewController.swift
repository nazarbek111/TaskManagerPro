//
//  UIKitTaskTableViewController.swift
//  TaskManagerPro
//

import UIKit
import SwiftUI

final class UIKitTaskTableViewController: UITableViewController, UISearchResultsUpdating {
    private let viewModel: UIKitTaskTableViewModel
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No results"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.isHidden = true
        return label
    }()

    private let searchController = UISearchController(searchResultsController: nil)

    init(tasks: [UIKitTaskRow]) {
        self.viewModel = UIKitTaskTableViewModel(tasks: tasks)
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        self.viewModel = UIKitTaskTableViewModel(tasks: [])
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIKit Table Demo"

        tableView.register(CustomTaskTableViewCell.self, forCellReuseIdentifier: CustomTaskTableViewCell.reuseID)
        tableView.backgroundColor = .systemBackground
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine

        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search tasks"
        definesPresentationContext = true

        tableView.backgroundView = emptyLabel
        updateEmptyState()
    }

    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        viewModel.setSearchText(text)
        tableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        let isEmpty = UIKitTaskTableViewModel.Section.allCases.allSatisfy { viewModel.items(in: $0).isEmpty }
        emptyLabel.isHidden = !isEmpty
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        UIKitTaskTableViewModel.Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sec = UIKitTaskTableViewModel.Section(rawValue: section) ?? .active
        return viewModel.items(in: sec).count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        UIKitTaskTableViewModel.Section(rawValue: section)?.title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomTaskTableViewCell.reuseID, for: indexPath) as? CustomTaskTableViewCell else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: "fallback")
        }
        let section = UIKitTaskTableViewModel.Section(rawValue: indexPath.section) ?? .active
        let item = viewModel.items(in: section)[indexPath.row]
        cell.configure(with: item)
        return cell
    }

    // Swipe to delete
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self else { completion(false); return }
            _ = self.viewModel.deleteItem(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateEmptyState()
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

// MARK: - SwiftUI bridge
struct UIKitTaskTableScreen: UIViewControllerRepresentable {
    let tasks: [UIKitTaskRow]

    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = UIKitTaskTableViewController(tasks: tasks)
        return UINavigationController(rootViewController: vc)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) { }
}
