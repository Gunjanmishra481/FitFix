import UIKit

class ShoesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let shoesItems = ShoesData.items  // Data source for shoes items
    var onItemSelected: ((ClothingItem) -> Void)?  // Closure to pass selected item back
    
    // Custom navigation bar container view
    private let customNavBarView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the custom navigation bar
        setupCustomNavBar()
        setupCustomBackButton()
        // Set up the collection view
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Custom Navigation Bar Setup
    private func setupCustomNavBar() {
        // Configure the custom navigation bar view
        customNavBarView.translatesAutoresizingMaskIntoConstraints = false
        customNavBarView.backgroundColor = .systemBackground // Matches the system background
        
        // Add the custom navigation bar view to the view hierarchy
        view.addSubview(customNavBarView)
        
        // Create the title label
        let titleLabel = UILabel()
        titleLabel.text = "Shoes"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the right icon buttons
        let calendarButton = UIButton(type: .system)
        calendarButton.setImage(UIImage(systemName: "calendar"), for: .normal)
        calendarButton.tintColor = .label
        calendarButton.addTarget(self, action: #selector(calendarButtonTapped), for: .touchUpInside)
        
        let profileButton = UIButton(type: .system)
        profileButton.setImage(UIImage(systemName: "person.crop.circle"), for: .normal)
        profileButton.tintColor = .label
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        
        // Create a horizontal stack view for the icons
        let iconsStackView = UIStackView(arrangedSubviews: [calendarButton, profileButton])
        iconsStackView.axis = .horizontal
        iconsStackView.spacing = 16
        iconsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a container stack view to hold the title and icons
        let containerStackView = UIStackView(arrangedSubviews: [titleLabel, iconsStackView])
        containerStackView.axis = .horizontal
        containerStackView.spacing = 16
        containerStackView.alignment = .center
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the container stack view to the custom navigation bar
        customNavBarView.addSubview(containerStackView)
        
        // Set up Auto Layout constraints
        NSLayoutConstraint.activate([
            customNavBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBarView.heightAnchor.constraint(equalToConstant: 50),
            
            containerStackView.centerYAnchor.constraint(equalTo: customNavBarView.centerYAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: customNavBarView.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: customNavBarView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupCustomBackButton() {
        // Create a custom back button
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonTapped))
        backButton.tintColor = .label // Set the tint color to match the label color
        
        // Assign the custom back button to the navigation item
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true) // Navigate back to the previous screen
    }

    
    // MARK: - Button Actions
    @objc internal override func calendarButtonTapped() {
        print("Calendar button tapped")
        // Navigate to calendar page or perform an action
    }
    
    @objc internal override func profileButtonTapped() {
        print("Profile button tapped")
        // Navigate to profile page or perform an action
    }
    
    // MARK: - Collection View DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shoesItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClothingCell", for: indexPath) as! ClothingCell
        let item = shoesItems[indexPath.item]
        cell.configure(with: item)
        
        // Ensure consistent cell styling
        cell.layer.cornerRadius = 10
        cell.backgroundColor = UIColor.white
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 0.2
        cell.layer.masksToBounds = false
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = shoesItems[indexPath.item]
        onItemSelected?(selectedItem)  // Pass selected item
        navigationController?.popViewController(animated: true)  // Return to previous view
    }
    
    // MARK: - Generate Collection View Layout
    private func generateLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(300))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(300))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        group.interItemSpacing = .fixed(10.0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)
        section.interGroupSpacing = 20
        return UICollectionViewCompositionalLayout(section: section)
    }
}
