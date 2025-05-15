import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
class AddClothesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var optionsCollectionView: UICollectionView!
    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var backgroundView: UIView!
    
    // MARK: - Properties
    let addItems = ["Take Photo", "Choose From Library"]
    var categories: [String] {
        return CategoryManager.shared.categories.map { $0.name }
    }
    var selectedImage: UIImage? = nil
    var hoveredCategory: String? = nil
    var addedItems: [ClothingItem] = []
//    7260AA
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(categoriesDidChange), name: .categoriesDidChange, object: nil)
        setupGradientBackground()
        setupTableViewStyle()
        resetTableViewSelection()
        optionsCollectionView.dataSource = self
        optionsCollectionView.delegate = self
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setupCollectionView()
        updateCategories()
        
        addButton.isEnabled = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTableViewSelection()
        if let selectedIndexPath = categoriesTableView.indexPathForSelectedRow {
            categoriesTableView.deselectRow(at: selectedIndexPath, animated: false)
            if let cell = categoriesTableView.cellForRow(at: selectedIndexPath) as? AddItemTableViewCell {
                cell.contentView.backgroundColor = .clear
                cell.titleLabel.textColor = UIColor(hex: "8E7CC3")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func categoriesDidChange() {
        categoriesTableView.reloadData()
    }
    
    private func updateCategories() {
        CategoryManager.shared.fetchCategories { [weak self] _ in
            self?.categoriesTableView.reloadData()
        }
    }
       
    // MARK: - Setup Methods
    private func setupTableViewStyle() {
        // Create blur effect for table background
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = categoriesTableView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        categoriesTableView.backgroundView = blurView
        categoriesTableView.backgroundColor = .clear
        
        // Style table view
        categoriesTableView.layer.cornerRadius = 20
        categoriesTableView.layer.masksToBounds = true
        categoriesTableView.layer.shadowOffset = CGSize(width: 0, height: 2)
        categoriesTableView.layer.shadowOpacity = 0.4
        categoriesTableView.separatorStyle = .singleLine
        categoriesTableView.separatorColor = .gray
        categoriesTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    private func resetTableViewSelection() {
            if let selectedIndexPath = categoriesTableView.indexPathForSelectedRow {
                categoriesTableView.deselectRow(at: selectedIndexPath, animated: true)
                
                if let cell = categoriesTableView.cellForRow(at: selectedIndexPath) as? AddItemTableViewCell {
                    cell.contentView.backgroundColor = .clear
                    cell.titleLabel.textColor = UIColor(hex: "8E7CC3")
                }
            }
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
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal  // Horizontal scrolling
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        collectionView.setCollectionViewLayout(layout, animated: false)
        optionsCollectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return CGSize(width: 170, height: collectionView.bounds.height - 10)
        } else if collectionView == optionsCollectionView {
            return CGSize(width: 100, height: collectionView.bounds.height - 10)
        }
        return CGSize(width: 100, height: 100)
    }

    // MARK: - UICollectionView DataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == optionsCollectionView {
            return addItems.count
        } else if collectionView == self.collectionView {
            return addedItems.count
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == optionsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClothingItemCollectionViewCell", for: indexPath) as! ClothingItemCollectionViewCell
            cell.titleLabel.text = addItems[indexPath.row]
            cell.iconImageView.image = (indexPath.row == 0) ? UIImage(systemName: "camera.fill") : UIImage(systemName: "photo.fill")
            styleCell(cell)
            cell.iconImageView.tintColor = UIColor(red: 85/255.0, green: 70/255.0, blue: 100/255.0, alpha: 1.0)
            return cell
        } else if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClothingCell", for: indexPath) as! ClothingItemCollectionViewCell
            if indexPath.row < addedItems.count {
                let item = addedItems[indexPath.row]
                
                // Download and set image from url
                if let url = URL(string: item.imageName) {
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url) {
                            DispatchQueue.main.async {
                                cell.iconImageView.image = UIImage(data: data)
                            }
                        } else {
                            // Handle error or set default image
                            DispatchQueue.main.async {
                                cell.iconImageView.image = UIImage(systemName: "photo") // Default image
                            }
                        }
                    }
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == optionsCollectionView {
            indexPath.row == 0 ? openCamera() : openPhotoLibrary()
        }
    }
    
    // MARK: - UITableViewDataSource Methods (Category List)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return categories.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddItemTableViewCell", for: indexPath) as! AddItemTableViewCell
            cell.titleLabel.text = categories[indexPath.row]
            cell.contentView.backgroundColor = .clear
            return cell
        }

        // MARK: - UITableViewDelegate Methods
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard selectedImage != nil else {
                tableView.deselectRow(at: indexPath, animated: true)
                showAlert(message: "Take picture or choose From photos")
                return
            }
            
            hoveredCategory = categories[indexPath.row]
            addButton.isEnabled = true
            
            if let cell = tableView.cellForRow(at: indexPath) as? AddItemTableViewCell {
                cell.contentView.backgroundColor = UIColor(hex: "8E7CC3")
                cell.titleLabel.textColor = UIColor.white
            }
        }
        
        func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
            if let cell = tableView.cellForRow(at: indexPath) as? AddItemTableViewCell {
                cell.contentView.backgroundColor = .clear
                cell.titleLabel.textColor = UIColor(hex: "8E7CC3")
            }
        }
    // MARK: - UIImagePickerController Delegate Methods
    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(message: "Camera not available.")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    func openPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            showAlert(message: "Photo Library not available.")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        selectedImage = info[.editedImage] as? UIImage
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.showAlert(message: "Select a category for the uploaded image")
            // Reset any existing selection when new image is picked
            self.resetTableViewSelection()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // MARK: - Adding Clothes to Collection
    @IBAction func addButtonTapped(_ sender: UIButton) {
            guard let image = selectedImage, let category = hoveredCategory else {
                showAlert(message: "Please select an image and a category.")
                return
            }

            // Disable the button and show loading animation
            sender.isEnabled = false
            let loadingIndicator = UIActivityIndicatorView(style: .large)
            loadingIndicator.center = view.center
            loadingIndicator.color = .black
            loadingIndicator.startAnimating()
            view.addSubview(loadingIndicator)

            // Upload image to Firebase Storage
            uploadImageToStorage(image) { [weak self] (imageURL, error) in
                guard let self = self else { return }
                loadingIndicator.stopAnimating()
                loadingIndicator.removeFromSuperview()

                if let imageURL = imageURL {
                    // Construct a new clothing item
                    let newItem = ClothingItem(
                        category: category,
                        imageName: imageURL,
                        firebaseID: nil
                    )
                    
                    // Reference to the current user's clothingItems subcollection
                    guard let userId = Auth.auth().currentUser?.uid else {
                        sender.isEnabled = true
                        self.showAlert(message: "No logged in user.")
                        return
                    }
                    
                    let db = Firestore.firestore()
                    db.collection("users")
                      .document(userId)
                      .collection("clothingItems")
                      .addDocument(data: [
                        "category": category,
                        "imageURL": imageURL
                      ]) { error in
                        DispatchQueue.main.async {
                            sender.isEnabled = true  // Re-enable the button
                            if let error = error {
                                self.showAlert(message: "Failed to add to Firestore: \(error.localizedDescription)")
                            } else {
                                // Update local data
                                ClothingData.items.append(newItem)
                                self.addedItems.append(newItem)
                                self.collectionView.reloadData()
                                self.showToast(message: "Item added")
                            }
                            self.resetSelections()
                        }
                      }
                } else {
                    DispatchQueue.main.async {
                        sender.isEnabled = true // Re-enable the button if upload fails
                        self.showAlert(message: "Failed to upload image: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
        private func resetSelections() {
            selectedImage = nil
            hoveredCategory = nil
            addButton.isEnabled = false
            resetTableViewSelection()
        }

        private func uploadImageToStorage(_ image: UIImage, completion: @escaping (String?, Error?) -> Void) {
            let storageRef = Storage.storage().reference().child("clothingImages/\(UUID().uuidString).jpg")
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
            
            let uploadTask = storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    completion(nil, error)
                } else {
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            completion(nil, error)
                            return
                        }
                        completion(downloadURL.absoluteString, nil)
                    }
                }
            }
        }
    
    func addImageToCategory(category: String, image: UIImage) {
        uploadImageToStorage(image) { [weak self] (imageURL, error) in
            guard let self = self, let imageURL = imageURL else {
                self?.showAlert(message: "Failed to upload image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let newItem = ClothingItem(category: category, imageName: imageURL, firebaseID: nil)
            // Append the new item to the unified data model
            ClothingData.items.append(newItem)
            // Also update the local array for this view controller
            self.addedItems.append(newItem)
            self.collectionView.reloadData() // Optionally refresh your UI here
        }
    }
    // MARK: - Helper Functions
    func styleCell(_ cell: UICollectionViewCell) {
        cell.contentView.layer.cornerRadius = 14
    }
    
    // Show alert (used for error messages)
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default))
        present(alert, animated: true)
    }
    
    // Show toast message (used for success feedback)
    func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 15
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
        
        let padding: CGFloat = 15
        let labelWidth = min(view.frame.width - 80, 250)
        let size = toastLabel.sizeThatFits(CGSize(width: labelWidth, height: .greatestFiniteMagnitude))
        
        // Calculate toast height and new y-position
        let toastHeight = size.height + padding * 2
        let margin: CGFloat = 10 // Space above the safe area
        let yPosition = view.frame.height - view.safeAreaInsets.bottom - margin
        
        // Set the frame with the adjusted y-position
        toastLabel.frame = CGRect(x: (view.frame.width - labelWidth) / 2,
                                  y: yPosition,
                                  width: labelWidth,
                                  height: toastHeight)
        
        view.addSubview(toastLabel)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            toastLabel.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        })
    }
}
