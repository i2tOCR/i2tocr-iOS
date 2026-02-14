//
//  HomeViewController.swift
//  i2tocr-iOS
//
//  Created by bardouei on 8/17/24.
//  Copyright © 2024 i2tocr. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SideMenu

class HomeViewController: BaseViewController,
                          UISearchBarDelegate,
                          UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UISearchResultsUpdating {

    // MARK: - IBOutlets
    @IBOutlet private weak var showListView: UIButton!
    @IBOutlet private weak var showGridView: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - Dependencies
    @Inject private var viewModel: HomeViewModel
    private let router: HomeNavigator = DIContainer.sharedInstance.getContainer(type: HomeNavigator.self)
    private let disposeBag = DisposeBag()

    // MARK: - UI State
    private var isGridView = false
    private var isSelectionMode = false
    private var selectedDocuments: Set<String> = []

    private let searchController = UISearchController(searchResultsController: nil)
    private var refreshControl: UIRefreshControl?
    private var longPressGesture: UILongPressGestureRecognizer!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        setupGestures()
        setupNavigationBar()
        setupSearchController()
        viewModel.loadAllDocuments()
    }

    // MARK: - Setup
    private func setupView() {
        setupSwipeGestures()
        configureCollectionView()
        configureToolbar()
        setupCameraButton()
        setupViewButtons()
        setupEmptyState()
        navigationController?.setToolbarHidden(true, animated: false)
    }

    private func setupGestures() {
        setupLongPressGesture()
    }

    private func setupNavigationBar() {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
//        titleConfig(title: "Home", backButton: "")
        navigationItem.title = "Home"
        addRightBarIcon(named: "setting")
    }

    private func setupSearchController() {
        searchController.searchBar.accessibilityIdentifier = "homeSearchBar"
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search documents..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Swipe & Gestures
    private func setupSwipeGestures() {
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe(_:)))
        rightSwipe.direction = .right
        rightSwipe.delegate = self

        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleLeftSwipe(_:)))
        leftSwipe.direction = .left
        leftSwipe.delegate = self

        collectionView.addGestureRecognizer(rightSwipe)
        collectionView.addGestureRecognizer(leftSwipe)
        collectionView.panGestureRecognizer.require(toFail: rightSwipe)
        collectionView.panGestureRecognizer.require(toFail: leftSwipe)
    }

    private func setupLongPressGesture() {
        longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        longPressGesture.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(longPressGesture)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            isSelectionMode = true
            let doc = viewModel.documents.value[indexPath.item]
            selectedDocuments.insert(doc.id)
            collectionView.reloadItems(at: [indexPath])
        }
    }

    // MARK: - CollectionView
    private func configureCollectionView() {
        collectionView.accessibilityIdentifier = "documentsCollectionView"
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(
            UINib(nibName: "MyScanCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: MyScanCollectionViewCell.reusedId
        )

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshDocuments), for: .valueChanged)
        if let refreshControl = refreshControl {
            collectionView.addSubview(refreshControl)
        }
    }

    // MARK: - Toolbar
    private func configureToolbar() {
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelectedDocuments))
        delete.tintColor = .red
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareSelectedDocuments))
        toolbarItems = [delete, flexible, share]
    }

    // MARK: - Camera
    private let cameraButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "camera.viewfinder"), for: .normal)
        btn.backgroundColor = .systemPurple
        btn.tintColor = .white
        btn.layer.cornerRadius = 25
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "cameraButton"
        return btn
    }()

    private func setupCameraButton() {
        cameraButton.isAccessibilityElement = true
        cameraButton.accessibilityTraits = .button
        view.addSubview(cameraButton)
        NSLayoutConstraint.activate([
            cameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cameraButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cameraButton.widthAnchor.constraint(equalToConstant: 50),
            cameraButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
    }

    @objc private func cameraButtonTapped() {
        showImageSourceSelection()
    }

    // MARK: - Animations
    private func animateCellForSwipe(at indexPath: IndexPath, direction: UISwipeGestureRecognizer.Direction) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        let offset: CGFloat = direction == .left ? -50 : 50
        let color: UIColor = direction == .left ? .systemBlue.withAlphaComponent(0.1) : .systemRed.withAlphaComponent(0.1)

        UIView.animate(withDuration: 0.25, animations: {
            cell.transform = CGAffineTransform(translationX: offset, y: 0)
            cell.backgroundColor = color
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                cell.transform = .identity
                cell.backgroundColor = .clear
            }
        }
    }

    // MARK: - Alerts & Dialogs
    private func showRenameDialogForCell(at indexPath: IndexPath) {
        let doc = viewModel.documents.value[indexPath.item]

        let alert = UIAlertController(title: "Rename Document", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.text = doc.title }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            let newTitle = alert.textFields?.first?.text ?? doc.title
            self?.viewModel.updateText(id: doc.id, text: newTitle)
        })

        present(alert, animated: true)
    }

    private func showDeleteConfirmationAlert() {
        let alert = UIAlertController(
            title: "Delete Documents",
            message: "Are you sure?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.selectedDocuments.forEach { self?.viewModel.delete(id: $0) }
            self?.selectedDocuments.removeAll()
        })
        present(alert, animated: true)
    }

    private func showDeleteConfirmationForCell(at indexPath: IndexPath) {
        let doc = viewModel.documents.value[indexPath.item]
        let alert = UIAlertController(
            title: "Delete",
            message: "Delete \(doc.title)?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel.delete(id: doc.id)
        })
        present(alert, animated: true)
    }

    private func showImageSourceSelection() {
        let alert = UIAlertController(title: "Add Document", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Navigation Bar Helpers
    private func setupLogoImageViewConstraints(_ imageView: UIImageView) {
        imageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }

    private func addTapGesture(to imageView: UIImageView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(settingsTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
    }

    @objc private func settingsTapped() {
        let menu = SideMenuNavigationController(rootViewController: UIViewController())
        present(menu, animated: true)
    }

    private func setupViewButtons() {
        let listImage = UIImage(systemName: "square.grid.2x2")
        showListView.setImage(listImage, for: .normal)
        showListView.tintColor = Colors.white
        showListView.setTitle("", for: .normal)

        let gridImage = UIImage(systemName: "list.bullet")
        showGridView.setImage(gridImage, for: .normal)
        showGridView.tintColor = Colors.white
        showGridView.setTitle("", for: .normal)

        showListView.backgroundColor = .clear
        showGridView.backgroundColor = .clear
    }
    
    private func setupEmptyState() {
        view.addSubview(emptyStateImageView)

        NSLayoutConstraint.activate([
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 200),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func updateEmptyState() {
        let isEmpty = viewModel.documents.value.isEmpty
        emptyStateImageView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    private func addRightBarIcon(named: String) {
        guard let image = UIImage(named: named) else { return }

        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.accessibilityIdentifier = "settingsButton"

        let item = UIBarButtonItem(customView: imageView)
        navigationItem.rightBarButtonItem = item

        addTapGesture(to: imageView)
    }
    
    @objc private func handleRightSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard !isSelectionMode else { return }

        let point = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            animateCellForSwipe(at: indexPath, direction: .right)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.showDeleteConfirmationForCell(at: indexPath)
            }
        }
    }
    
    @objc func deleteSelectedDocuments() {
        guard !selectedDocuments.isEmpty else { return }

        let alert = UIAlertController(
            title: "Delete Documents",
            message: "Are you sure you want to delete selected documents?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.selectedDocuments.forEach {
                self?.viewModel.delete(id: $0)
            }
            self?.selectedDocuments.removeAll()
            self?.isSelectionMode = false
        })

        present(alert, animated: true)
    }
    
    @objc func shareSelectedDocuments() {
        guard !selectedDocuments.isEmpty else { return }

        let docs = viewModel.documents.value.filter {
            selectedDocuments.contains($0.id)
        }

        let combinedText = docs.map { $0.textDic }.joined(separator: "\n\n---\n\n")
        let activityVC = UIActivityViewController(
            activityItems: [combinedText],
            applicationActivities: nil
        )

        present(activityVC, animated: true)
    }
    
    private func renameDocument(at indexPath: IndexPath, to newTitle: String) {
        let doc = viewModel.documents.value[indexPath.item]
        viewModel.updateText(id: doc.id, text: newTitle)
    }
    
    @objc private func handleLeftSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard !isSelectionMode else { return }

        let point = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }

        animateCellForSwipe(at: indexPath, direction: .left)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.showRenameDialogForCell(at: indexPath)
        }
    }
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "doc.text.magnifyingglass")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightGray
        imageView.alpha = 0.7
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "emptyStateView"
        return imageView
    }()
    
    // MARK: - Bindings
    private func setupBindings() {
        viewModel.documents
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.reloadData()
                self?.updateEmptyState()
            })
            .disposed(by: disposeBag)
    }

    @objc private func refreshDocuments() {
        viewModel.loadAllDocuments()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.documents.value.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MyScanCollectionViewCell.reusedId,
            for: indexPath
        ) as! MyScanCollectionViewCell

        let document = viewModel.documents.value[indexPath.item]
        cell.configure(with: document)
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        viewModel.search(query: query)
    }
}
