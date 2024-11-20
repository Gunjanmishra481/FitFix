import UIKit

class HomeTabViewController: UICollectionViewController {
    
    // Custom navigation bar container view
    private let customNavBarView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the default navigation bar with a back button
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "FitFix"
        
        // Add the custom navigation bar for title and icons below the back button
        setupCustomNavBar()

        // Collection View setup
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(generateHorizontalLayout(), animated: true)
        collectionView.alwaysBounceVertical = false // Prevent vertical bouncing
    }
    
    // MARK: - Custom Navigation Bar Setup
    private func setupCustomNavBar() {
        // Configure the custom navigation bar view
        customNavBarView.translatesAutoresizingMaskIntoConstraints = false
        customNavBarView.backgroundColor = .systemBackground
        
        // Add the custom navigation bar view to the view hierarchy
        view.addSubview(customNavBarView)
        
        // Create the title label
        let titleLabel = UILabel()
        titleLabel.text = "Wed 20 Nov ☁️"
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
            // Position the custom navigation bar at the top
            customNavBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBarView.heightAnchor.constraint(equalToConstant: 50),
            
            // Center the container stack view within the custom navigation bar
            containerStackView.centerYAnchor.constraint(equalTo: customNavBarView.centerYAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: customNavBarView.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: customNavBarView.trailingAnchor, constant: -16)
        ])
        
        // Adjust collection view's top anchor to start below the custom navigation bar
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: customNavBarView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    @objc func backToHome() {
        // Check if the view controller was pushed
        if let navigationController = self.navigationController {
            for viewController in navigationController.viewControllers {
                if viewController is HomeTabViewController {
                    navigationController.popToViewController(viewController, animated: true)
                    return
                }
            }
        }
        
        // If presented modally, dismiss it
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OutfitEditViewController" {
            let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationItem.backBarButtonItem = backButton
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
        // Navigate to profile page or perform an action
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let plannerVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            navigationController?.pushViewController(plannerVC, animated: true)
        } else {
            print("Failed to instantiate PlannerViewController")
        }
    }
    
    // MARK: - Collection View DataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return OutfitData.shared.outfitItems.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OutfitCell", for: indexPath) as! OutfitCollectionViewCell
        let outfitItem = OutfitData.shared.outfitItems[indexPath.row]
        cell.outfitImageView.image = UIImage(named: outfitItem.imageName)
        cell.layer.cornerRadius = 20
        cell.backgroundColor = UIColor.white
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 0.2
        cell.layer.masksToBounds = false
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    
    // Layout generation for horizontal scrolling
    func generateHorizontalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (section, env) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Add spacing between items
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .fractionalHeight(0.8))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous // Horizontal scrolling only
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 0, trailing: 16)
            return section
        }
        return layout
    }
    
}
