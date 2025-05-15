import UIKit
import FirebaseFirestore
import FirebaseAuth

class CategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundView: UIView!
    
    // MARK: - Properties
    var categories: [Category] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    private let customNavBarView = UIView()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCustomNavBar()
        setupGradientBackground()
        // Configure navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Your Wardrobe"
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(hex: "#554664"),
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: .bold)
        ]
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = generateLayout()
        collectionView.backgroundColor = .clear
        
        CategoryManager.shared.fetchCategories { [weak self] fetchedCategories in
            self?.categories = fetchedCategories
        }
        
        ClothingData.fetchClothingItems { [weak self] _ in
            self?.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData() // This refreshes the counts
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OutfitEditViewController" {
            let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationItem.backBarButtonItem = backButton
        }
    }
    // MARK: - Setup Methods
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.95, green: 0.92, blue: 1.0, alpha: 1.0).cgColor,  // Light purple
            UIColor(red: 0.78, green: 0.72, blue: 1.0, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = backgroundView.bounds
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupCustomNavBar() {
        customNavBarView.translatesAutoresizingMaskIntoConstraints = false
        customNavBarView.backgroundColor = .clear
        view.addSubview(customNavBarView)
        
        // Title label (currently empty; you can customize as needed)
        let titleLabel = UILabel()
        titleLabel.text = ""
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Calendar button
        let calendarButton = UIButton(type: .system)
        calendarButton.setImage(UIImage(systemName: ""), for: .normal)
        calendarButton.tintColor = .label
        calendarButton.addTarget(self, action: #selector(calendarButtonTapped), for: .touchUpInside)
        
        // Profile button
        let profileButton = UIButton(type: .system)
        profileButton.setImage(UIImage(systemName: ""), for: .normal)
        profileButton.tintColor = .label
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        
        // Stack view for the buttons
        let iconsStackView = UIStackView(arrangedSubviews: [calendarButton, profileButton])
        iconsStackView.axis = .horizontal
        iconsStackView.spacing = 16
        iconsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Container stack view for title and icons
        let containerStackView = UIStackView(arrangedSubviews: [titleLabel, iconsStackView])
        containerStackView.axis = .horizontal
        containerStackView.spacing = 16
        containerStackView.alignment = .center
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        customNavBarView.addSubview(containerStackView)
        
        // Auto Layout for custom nav bar and container stack view
        NSLayoutConstraint.activate([
            customNavBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBarView.heightAnchor.constraint(equalToConstant: 50),
            
            containerStackView.centerYAnchor.constraint(equalTo: customNavBarView.centerYAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: customNavBarView.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: customNavBarView.trailingAnchor, constant: -16)
        ])
        
        // Adjust collection view's top anchor so it starts below the custom navigation bar
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: customNavBarView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Navigation Methods
    private func navigateToClothingVC(category: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let clothingVC = storyboard.instantiateViewController(withIdentifier: "ClothingViewController") as? ClothingViewController {
            // Pass the selected category to ClothingViewController
            clothingVC.selectedCategory = category
            navigationController?.pushViewController(clothingVC, animated: true)
        }
    }
    
    // MARK: - Button Actions
    @objc override func calendarButtonTapped() {
        print("Calendar button tapped")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let plannerVC = storyboard.instantiateViewController(withIdentifier: "PlannerViewController") as? PlannerViewController {
            navigationController?.pushViewController(plannerVC, animated: true)
        } else {
            print("Failed to instantiate PlannerViewController")
        }
    }
    
    @objc override func profileButtonTapped() {
        print("Profile button tapped")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            navigationController?.pushViewController(profileVC, animated: true)
        } else {
            print("Failed to instantiate ProfileViewController")
        }
    }
    
    // MARK: - UICollectionView Layout
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 20
        layout.itemSize = CGSize(width: 170, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 16, left: spacing, bottom: 16, right: spacing)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 10
        return layout
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return categories.count + 1
        }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Last cell is used to add a new category
        
        if indexPath.item < categories.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            let category = categories[indexPath.item]
            cell.label.text = category.name
            // This already dynamically calculates from ClothingData.items
            let countForCategory = ClothingData.items.filter { $0.category == category.name }.count
            cell.count.text = "\(countForCategory)"
            return cell
        }
        if indexPath.item == categories.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCategoryCell", for: indexPath)
            cell.contentView.layer.cornerRadius = 10
            cell.contentView.layer.masksToBounds = true
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            let category = categories[indexPath.item]
            cell.backgroundColor = UIColor(red: 210/255, green: 185/255, blue: 211/255, alpha: 1.0)
            cell.contentView.layer.cornerRadius = 12
            cell.contentView.layer.masksToBounds = true
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOpacity = 0.05
            cell.layer.shadowOffset = CGSize(width: 2, height: 2)
            cell.layer.shadowRadius = 4
            cell.layer.masksToBounds = false
            
            // Configure the cell with category details
            cell.label.text = category.name
            cell.count.text = "\(category.count)"
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if indexPath.item == categories.count {
                showAddCategoryAlert()
            } else {
                let selectedCategory = categories[indexPath.item]
                navigateToClothingVC(category: selectedCategory.name)
            }
        }
    
    // MARK: - Alert for Adding a New Category
    func showAddCategoryAlert() {
            let alertController = UIAlertController(title: "New Category",
                                                    message: "Enter category name",
                                                    preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Category Name"
            }
            
            let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
                guard let name = alertController.textFields?.first?.text, !name.isEmpty else {
                    return
                }
                
                // Construct the new Category
                let newCategory = Category(
                    id: UUID(),
                    name: name,
                    iconName: "plus",
                    count: 0,
                    firebaseID: nil
                )
                
                // Add to Firestore subcollection
                guard let userId = Auth.auth().currentUser?.uid else {
                    self?.showAlert(message: "No logged in user.")
                    return
                }
                
                let db = Firestore.firestore()
                db.collection("users")
                  .document(userId)
                  .collection("categories")
                  .addDocument(data: [
                    "name": name,
                    "iconName": "plus",
                    "count": 0
                  ]) { error in
                    if let error = error {
                        self?.showAlert(message: "Failed to add category: \(error.localizedDescription)")
                    } else {
                        CategoryManager.shared.categories.append(newCategory)
                        self?.categories = CategoryManager.shared.categories
                        self?.collectionView.reloadData()
                    }
                }
            }
            
            alertController.addAction(addAction)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    // MARK: - Navigation (Example: Back to Home)
    @objc func backToHome() {
        if let navigationController = self.navigationController {
            for viewController in navigationController.viewControllers {
                if viewController is HomeTabViewController {
                    navigationController.popToViewController(viewController, animated: true)
                    return
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
    
