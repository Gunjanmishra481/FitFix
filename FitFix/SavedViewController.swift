import UIKit

class SavedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundView: UIView!
    var savedItems: [ClothingItem] = [] {
           didSet {
               collectionView?.reloadData()
           }
       }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Update savedItems from persisted data whenever view appears
        savedItems = OutfitEditableViewController.persistedOutfits
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        // Set up the navigation bar
        setupNavigationBar(
            title: "Saved",
            leftIcon: "arrow.backward",          // Left icon: Back arrow
            rightIcons: ["calendar", "person.crop.circle"] // Right icons: Calendar and Profile
        )
        
        // Configure the collection view
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
    }

    // MARK: - DataSource Methods
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClothingCell", for: indexPath) as! ClothingCell
        let item = savedItems[indexPath.item]
        cell.configure(with: item) // Assuming ClothingCell has a configure method that accepts a ClothingItem
        
        // Apply the styling for corner radius, shadow, etc. on the cell
        cell.layer.cornerRadius = 10
        cell.backgroundColor = UIColor.white
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 0.2
        cell.layer.masksToBounds = false
        
        return cell
    }

    // MARK: - Layout
    func generateLayout() -> UICollectionViewCompositionalLayout {
        // Create item size
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(300))
        
        // Create an item using the above item size
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Create group size (2 items per row)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(300)) // Adjust to full width
        
        // Create a group (2 items in a row)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        // Set inter-item spacing (space between the cells)
        group.interItemSpacing = .fixed(10.0)
        
        // Create a section with the defined group
        let section = NSCollectionLayoutSection(group: group)
        
        // Set section insets (padding around the section)
        section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)
        
        // Set inter-group spacing (spacing between rows)
        section.interGroupSpacing = 20
        
        // Create the compositional layout with the section
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        // Ensure that the layout scrolls vertically
        layout.configuration.scrollDirection = .vertical
        
        return layout
    }
}

