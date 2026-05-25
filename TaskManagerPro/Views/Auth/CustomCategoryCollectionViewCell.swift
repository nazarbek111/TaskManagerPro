//
//  CustomCategoryCollectionViewCell.swift
//  TaskManagerPro
//

import UIKit

final class CustomCategoryCollectionViewCell: UICollectionViewCell {
    static let reuseID = "CustomCategoryCollectionViewCell"

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .label
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()

    private let vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView.backgroundColor = UIColor.secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        contentView.addSubview(iconView)
        contentView.addSubview(vStack)
        vStack.addArrangedSubview(nameLabel)
        vStack.addArrangedSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),

            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            vStack.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8),
            vStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with item: TaskCategoryItem) {
        nameLabel.text = item.name
        descriptionLabel.text = item.description
        iconView.image = UIImage(systemName: item.systemIcon)
    }
}
