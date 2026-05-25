//
//  TaskCategoryCollectionViewController.swift
//  TaskManagerPro
//

import UIKit
import SwiftUI

final class TaskCategoryCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private let viewModel: TaskCategoryCollectionViewModel
    private var collectionView: UICollectionView!

    init(viewModel: TaskCategoryCollectionViewModel = TaskCategoryCollectionViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = TaskCategoryCollectionViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Categories"

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        cv.dataSource = self
        cv.delegate = self
        cv.register(CustomCategoryCollectionViewCell.self, forCellWithReuseIdentifier: CustomCategoryCollectionViewCell.reuseID)
        view.addSubview(cv)
        self.collectionView = cv

        NSLayoutConstraint.activate([
            cv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cv.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Sound button
        let soundButton = UIBarButtonItem(title: "Play Success Sound", style: .plain, target: self, action: #selector(playSoundTapped))
        navigationItem.rightBarButtonItem = soundButton
    }

    @objc private func playSoundTapped() {
        SoundService.shared.playSuccessSound()
    }

    // MARK: - Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCategoryCollectionViewCell.reuseID, for: indexPath) as? CustomCategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        let item = viewModel.items[indexPath.item]
        cell.configure(with: item)
        return cell
    }

    // MARK: - Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalPadding: CGFloat = 16 + 16 + 12 // left + right + interitem
        let available = collectionView.bounds.width - totalPadding
        let itemWidth = floor(available / 2)
        return CGSize(width: itemWidth, height: 110)
    }
}

// MARK: - SwiftUI bridge
struct TaskCategoryCollectionScreen: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = TaskCategoryCollectionViewController()
        return UINavigationController(rootViewController: vc)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
