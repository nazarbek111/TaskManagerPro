//
//  CustomTaskTableViewCell.swift
//  TaskManagerPro
//

import UIKit

final class CustomTaskTableViewCell: UITableViewCell {
    static let reuseID = "CustomTaskTableViewCell"

    private let statusImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemGreen
        iv.setContentHuggingPriority(.required, for: .horizontal)
        iv.setContentCompressionResistancePriority(.required, for: .horizontal)
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 2
        return label
    }()

    private let priorityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()

    private let dueDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption2)
        label.textColor = .tertiaryLabel
        return label
    }()

    private let vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        selectionStyle = .none
        contentView.addSubview(statusImageView)
        contentView.addSubview(vStack)
        vStack.addArrangedSubview(titleLabel)
        vStack.addArrangedSubview(priorityLabel)
        vStack.addArrangedSubview(dueDateLabel)

        NSLayoutConstraint.activate([
            statusImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusImageView.widthAnchor.constraint(equalToConstant: 22),
            statusImageView.heightAnchor.constraint(equalToConstant: 22),

            vStack.leadingAnchor.constraint(equalTo: statusImageView.trailingAnchor, constant: 12),
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with row: UIKitTaskRow) {
        titleLabel.text = row.title
        priorityLabel.text = "Priority: \(row.priority.capitalized)"
        if let due = row.dueDate {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .short
            dueDateLabel.text = "Due: \(df.string(from: due))"
        } else {
            dueDateLabel.text = "No due date"
        }
        let imageName = row.isCompleted ? "checkmark.circle.fill" : "circle"
        statusImageView.image = UIImage(systemName: imageName)
        statusImageView.tintColor = row.isCompleted ? .systemGreen : .tertiaryLabel
    }
}
