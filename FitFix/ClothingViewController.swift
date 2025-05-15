import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ClothingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    private let noItemsView = UIView()
    private let messageLabel = UILabel()
    private let arrowImageView = UIImageView()
    // This property is set before the view controller is pushed.
    var selectedCategory: String?
    
    // The data source for clothing items; initially empty.
    var clothingItems: [ClothingItem] = []
    
    // Closure to pass the selected item back (if needed)
    var onItemSelected: ((ClothingItem) -> Void)?
    
    // Custom navigation bar container view
    private let customNavBarView = UIView()
    
    // Properties for deletion functionality
    private var isEditingMode = false
    private var selectedItems: [IndexPath] = []
    private var deleteButton: UIBarButtonItem!
    private var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up noItemsView
        setupNoItemsView()
        setupGradientBackground()

        // Initially update noItemsView
        updateNoItemsView()
        // Filter clothing items based on the selected category.
        if let category = selectedCategory {
            clothingItems = ClothingData.items.filter { $0.category == category }
        } else {
            clothingItems = []
        }
        NotificationCenter.default.addObserver(self,
                                                  selector: #selector(refreshClothingItems),
                                                  name: .clothingItemsDidChange,
                                                  object: nil)

        // Optionally update the standard navigation title.
        navigationItem.title = selectedCategory ?? "Clothing"
        
        // Set up the custom navigation bar and back button.
        setupCustomBackButton()
        setupEditButton()
        
        // Set up the collection view.
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.backgroundColor = .clear // Make the collection view transparent
        collectionView.allowsMultipleSelection = true
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshClothingItems()
    }
    @objc private func refreshClothingItems() {
        if let category = selectedCategory {
            clothingItems = ClothingData.items.filter { $0.category == category }
        } else {
            clothingItems = []
        }
        print("Refreshed clothingItems count: \(clothingItems.count)") // Debug
        collectionView.reloadData()
        updateNoItemsView()
    }
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.95, green: 0.92, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.78, green: 0.72, blue: 1.0, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = backgroundView.bounds
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
    }
    private func setupNoItemsView() {
        noItemsView.backgroundColor = .clear
        
        messageLabel.text = "No items yet. Upload one to view here!"
        messageLabel.textColor = UIColor(hex: "A293CA")
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 18)
        
        arrowImageView.image = UIImage(systemName: "arrow.down")
        arrowImageView.tintColor = .black
        arrowImageView.contentMode = .scaleAspectFit
        
        noItemsView.addSubview(messageLabel)
        noItemsView.addSubview(arrowImageView)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: noItemsView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: noItemsView.centerYAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: noItemsView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: noItemsView.trailingAnchor, constant: -20),
            
            arrowImageView.centerXAnchor.constraint(equalTo: noItemsView.centerXAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 30),
            arrowImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        if let tabBarHeight = self.tabBarController?.tabBar.frame.height {
            arrowImageView.bottomAnchor.constraint(equalTo: noItemsView.bottomAnchor, constant: -tabBarHeight - 20).isActive = true
        } else {
            arrowImageView.bottomAnchor.constraint(equalTo: noItemsView.bottomAnchor, constant: -20).isActive = true
        }
        
        view.addSubview(noItemsView)
        noItemsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noItemsView.topAnchor.constraint(equalTo: view.topAnchor),
            noItemsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noItemsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noItemsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    private func startArrowAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.arrowImageView.transform = CGAffineTransform(translationX: 0, y: -10)
        }, completion: nil)
    }

    private func stopArrowAnimation() {
        arrowImageView.layer.removeAllAnimations()
        arrowImageView.transform = .identity
    }
    private func updateNoItemsView() {
        print("clothingItems.count: \(clothingItems.count)") // Debug
        if clothingItems.isEmpty {
            print("Showing noItemsView")
            noItemsView.isHidden = false
            view.bringSubviewToFront(noItemsView) // Ensure it’s on top when shown
            startArrowAnimation()
        } else {
            print("Hiding noItemsView")
            noItemsView.isHidden = true
            stopArrowAnimation()
        }
    }
    
    // MARK: - Custom Navigation Bar Setup
    private func setupCustomBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonTapped))
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupEditButton() {
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteButtonTapped))
        deleteButton.tintColor = .red
        deleteButton.isEnabled = false
        
        navigationItem.rightBarButtonItems = [editButton]
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func editButtonTapped() {
        isEditingMode = !isEditingMode
        editButton.title = isEditingMode ? "Cancel" : "Edit"
        
        if isEditingMode {
            navigationItem.rightBarButtonItems = [editButton, deleteButton]
        } else {
            navigationItem.rightBarButtonItems = [editButton]
            // Clear selections when canceling edit mode
            selectedItems.removeAll()
            deleteButton.isEnabled = false
            collectionView.reloadData()
        }
    }
    
    @objc private func deleteButtonTapped() {
        let alertController = UIAlertController(
            title: "Delete Items",
            message: "Are you sure you want to delete the selected items?",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteSelectedItems()
        })
        
        present(alertController, animated: true)
    }
    
    private func deleteSelectedItems() {
        // Sort indices in descending order to avoid index issues when removing items
        let sortedIndices = selectedItems.sorted { $0.item > $1.item }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(message: "No user logged in.")
            return
        }
        
        let db = Firestore.firestore()
        let storage = Storage.storage()
        let dispatchGroup = DispatchGroup()
        
        for indexPath in sortedIndices {
            let item = clothingItems[indexPath.item]
            guard let firebaseID = item.firebaseID else { continue }
            
            dispatchGroup.enter()
            
            // Delete from Firestore
            db.collection("users").document(userId).collection("clothingItems").document(firebaseID).delete { [weak self] error in
                if let error = error {
                    print("Error deleting document: \(error)")
                    dispatchGroup.leave()
                    return
                }
                
                // Delete from Storage if it's a URL
                if let imageURL = URL(string: item.imageName) {
                    // Extract the path from the URL (assuming Firebase Storage URL format)
                    let path = imageURL.lastPathComponent
                    let storageRef = storage.reference().child("users/\(userId)/images/\(path)")
                    
                    storageRef.delete { error in
                        if let error = error {
                            print("Error deleting image: \(error)")
                        } else {
                            print("Image deleted successfully")
                        }
                        dispatchGroup.leave()
                    }
                } else {
                    dispatchGroup.leave()
                }
            }
            
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            // Update local data model
            for indexPath in sortedIndices {
                if indexPath.item < self.clothingItems.count {
                    // Remove from the local array
                    let deletedItem = self.clothingItems.remove(at: indexPath.item)
                    
                    // Also remove from the global items array
                    if let globalIndex = ClothingData.items.firstIndex(where: { $0.firebaseID == deletedItem.firebaseID }) {
                        ClothingData.items.remove(at: globalIndex)
                    }
                }
            }
            
            // Update category counts via notification
            NotificationCenter.default.post(name: .clothingItemsDidChange, object: nil)
            
            // Reset editing state
            self.isEditingMode = false
            self.editButton.title = "Edit"
            self.navigationItem.rightBarButtonItems = [self.editButton]
            self.selectedItems.removeAll()
            self.deleteButton.isEnabled = false
            self.updateNoItemsView() // Add this line
            // Reload collection view
            self.collectionView.reloadData()
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - UICollectionView DataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clothingItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClothingCell", for: indexPath) as! ClothingCell
        let item = clothingItems[indexPath.item]
        
        // Configure the cell
        cell.configure(with: item)
        
        // Apply cell styling
        cell.layer.cornerRadius = 10
        cell.backgroundColor = .white
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 0.2
        cell.layer.masksToBounds = false
        
        // Show selection state if in editing mode
        if isEditingMode {
            cell.showSelectionIndicator(isSelected: selectedItems.contains(indexPath))
        } else {
            cell.hideSelectionIndicator()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditingMode {
            // Handle selection in edit mode
            selectedItems.append(indexPath)
            deleteButton.isEnabled = !selectedItems.isEmpty
            collectionView.reloadItems(at: [indexPath])
        } else {
            // Handle normal selection (pass selected item back)
            let selectedItem = clothingItems[indexPath.item]
            onItemSelected?(selectedItem)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func didSelectItem(_ item: ClothingItem) {
        print("Selected item: \(item.imageName)") // Debugging
        onItemSelected?(item)
        navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isEditingMode {
            if let index = selectedItems.firstIndex(of: indexPath) {
                selectedItems.remove(at: index)
                deleteButton.isEnabled = !selectedItems.isEmpty
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    // MARK: - Generate Collection View Layout
    func generateLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .absolute(300))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(300))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        group.interItemSpacing = .fixed(10.0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)
        section.interGroupSpacing = 20
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
