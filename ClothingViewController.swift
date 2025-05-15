import UIKit

class ClothingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let clothingItems = ClothingData.items  // Access the data from ClothingData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Set the collection view layout to use the compositional layout
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        
        // Ensure that the collection view scrolls vertically (default behavior)
        collectionView.isScrollEnabled = true  // Optional: Ensures that scrolling is enabled
    }
    
    // DataSource Method
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clothingItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClothingCell", for: indexPath) as! ClothingCell
        let item = clothingItems[indexPath.item]
        cell.configure(with: item)
        
        // Apply the styling for corner radius, shadow, etc. on the cell
        cell.layer.cornerRadius = 10
        cell.backgroundColor = UIColor.systemGray6
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 0.2
        cell.layer.masksToBounds = false
        
        return cell
    }
    
    // Function to generate Compositional Layout with 2 items per row
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
