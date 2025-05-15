import UIKit

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class HomeScreenViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    @IBOutlet weak var outfitButton: UIButton! // Connect this in Interface Builder
    @IBOutlet weak var ContentView: UIView!
    @IBOutlet weak var RecommendedOutfit: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var custom: UIButton!
    
    private let customNavBarView = UIView()
    private let backgroundView = UIView()
    private var calendarButton: UIButton!
    private var profileButton: UIButton!
    private let noOutfitLabel = UILabel()
    // Add filtered events array
    private var filteredEvents: [Event] = []
    private let db = Firestore.firestore()
    
    // Coach marks controller
    private let coachMarksController = CoachMarksController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        custom.layer.cornerRadius=14
        custom.clipsToBounds = true
        outfitButton.layer.cornerRadius = 14
        outfitButton.backgroundColor = .clear
        outfitButton.clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        
        // Set the gradient colors
        gradientLayer.colors = [
            UIColor(red: 160/255, green: 145/255, blue: 190/255, alpha: 1).cgColor,  // #A091BE (Soft lavender-gray)
            UIColor(red: 200/255, green: 185/255, blue: 230/255, alpha: 1).cgColor   // #C8B9E6 (Light pastel purple)
        ]
        
        
        
        // Set the gradient direction (top-left to bottom-right for a diagonal effect)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        // Match the layer frame to the button's bounds
        gradientLayer.frame = outfitButton.bounds
        
        // Optional: Add corner radius to match the button's rounded corners
        gradientLayer.cornerRadius = outfitButton.layer.cornerRadius
        
        // Insert the gradient layer into the button's layer
        outfitButton.layer.insertSublayer(gradientLayer, at: 0)
        
        // Ensure the button's text remains visible
        outfitButton.setTitleColor(.white, for: .normal) // Adjust text color if needed
        outfitButton.layer.masksToBounds = true
        
        setupBackgroundView()
        setupCustomNavBar()
        setupNavigationBar()
        setupDailyRefresh()
        setupUI()
        ContentView.addBlurEffect()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        ContentView.layer.borderWidth = 1
        ContentView.layer.borderColor = UIColor(hex: "A293CA").cgColor
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 10
        }
        collectionView.isPagingEnabled = true
        
        // Update filtered events and page control
        updateFilteredEvents()
        pageControl.numberOfPages = filteredEvents.count
        
        setupCollectionViewBackground()
        noOutfitLabel.text = "Add Clothing Item To Get Recommendation"
        noOutfitLabel.textAlignment = .center
        noOutfitLabel.textColor = UIColor(hex: "A293CA")
        noOutfitLabel.font = UIFont.systemFont(ofSize: 16)
        noOutfitLabel.numberOfLines = 0
        RecommendedOutfit.addSubview(noOutfitLabel)
        noOutfitLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noOutfitLabel.centerXAnchor.constraint(equalTo: RecommendedOutfit.centerXAnchor),
            noOutfitLabel.centerYAnchor.constraint(equalTo: RecommendedOutfit.centerYAnchor),
            noOutfitLabel.widthAnchor.constraint(equalTo: RecommendedOutfit.widthAnchor, multiplier: 0.8)
        ])
        noOutfitLabel.isHidden = false
        
        // Setup coach marks
        setupCoachMarks()
    }
    
    // Setup coach marks
    private func setupCoachMarks() {
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        
        // Customize coach marks appearance
        coachMarksController.overlay.backgroundColor = UIColor(white: 0.0, alpha: 0.65)
        coachMarksController.overlay.isUserInteractionEnabled = true
        
        // Skip view setup (optional)
        let skipView = CoachMarkSkipDefaultView()
        skipView.setTitle("Skip", for: .normal)
        
        // Fix: Use UIBlurEffect directly instead of .blur
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = skipView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        skipView.insertSubview(blurView, at: 0) // Insert at bottom to keep other UI elements visible

        skipView.alpha = 0.8
        coachMarksController.skipView = skipView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if this is the first launch
        let userDefaults = UserDefaults.standard
        let hasSeenCoachMarks = userDefaults.bool(forKey: "HasSeenCoachMarks")
        
        if !hasSeenCoachMarks {
            // Start coach marks
            self.coachMarksController.start(in: .window(over: self))
            userDefaults.set(true, forKey: "HasSeenCoachMarks")
        }
    }
    
    // MARK: - CoachMarksControllerDataSource
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 4 // Updated from 3 to 4 to include the '+' button coach mark
    }
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch index {
        case 0:
            return coachMarksController.helper.makeCoachMark(for: ContentView)
        case 1:
            return coachMarksController.helper.makeCoachMark(for: calendarButton)
        case 2:
            return coachMarksController.helper.makeCoachMark(for: collectionView)
        case 3:
            // Access the tab bar and find the '+' button (assumed to be the middle button at index 2)
            if let tabBar = self.tabBarController?.tabBar {
                let tabBarButtons = tabBar.subviews.filter { $0.isKind(of: NSClassFromString("UITabBarButton")!) }
                                           .sorted { $0.frame.origin.x < $1.frame.origin.x }
                if tabBarButtons.count > 2 {
                    let plusButtonView = tabBarButtons[2] // Middle button in a 5-item tab bar
                    return coachMarksController.helper.makeCoachMark(for: plusButtonView)
                } else {
                    print("Warning: Could not find the '+' button in the tab bar.")
                    return coachMarksController.helper.makeCoachMark(for: view) // Fallback to the main view
                }
            } else {
                print("Warning: Tab bar not found.")
                return coachMarksController.helper.makeCoachMark(for: view) // Fallback to the main view
            }        default:
            return coachMarksController.helper.makeCoachMark(for: view)
        }
    }
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(
            withArrow: true,
            arrowOrientation: coachMark.arrowOrientation
        )
        
        switch index {
        case 0:
            coachViews.bodyView.hintLabel.text = "This is your outfit recommendation area where you'll see your daily outfit suggestion."
            coachViews.bodyView.nextLabel.text = "Next"
        case 1:
            coachViews.bodyView.hintLabel.text = "Tap here to view your calendar and scheduled events."
            coachViews.bodyView.nextLabel.text = "Next"
        case 2:
            coachViews.bodyView.hintLabel.text = "Swipe through your upcoming events for the next week."
            coachViews.bodyView.nextLabel.text = "Next"
        case 3:
            coachViews.bodyView.hintLabel.text = "Tap the '+' button to add a new clothing item or event."
            coachViews.bodyView.nextLabel.text = "Got it!"
        default:
            break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    // MARK: - CoachMarksControllerDelegate
    
    func coachMarksController(_ coachMarksController: CoachMarksController, willShow coachMark: CoachMark, at index: Int) {
        // You can perform additional actions before a coach mark appears
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, didShow coachMark: CoachMark, at index: Int) {
        // You can perform additional actions after a coach mark appears
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, didHide coachMark: CoachMark, at index: Int) {
        // You can perform additional actions after a coach mark disappears
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, willHide coachMark: CoachMark, at index: Int) {
        // You can perform additional actions before a coach mark disappears
    }
    
    private func setupDailyRefresh() {
        Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { [weak self] _ in
            self?.updateFilteredEvents()
            self?.collectionView.reloadData()
            self?.pageControl.numberOfPages = self?.filteredEvents.count ?? 0
        }
    }
    private func setupUI() {
          // Setup corner radius for text fields
        ContentView.layer.cornerRadius = 12  // Change 12 to your desired radius
        ContentView.clipsToBounds = true      // Ensures that subviews are clipped to the rounded corners

      }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EventManager.shared.loadEvents {
            self.updateFilteredEvents()
            self.collectionView.reloadData()
            self.pageControl.numberOfPages = self.filteredEvents.count
            self.collectionView.backgroundView?.isHidden = !self.filteredEvents.isEmpty
        }
    }
    
    
    // Add filtering function
    private func updateFilteredEvents() {
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Calculate date 7 days from now (making it an 8-day window including today)
        guard let sevenDaysFromNow = calendar.date(byAdding: .day, value: 7, to: currentDate) else { return }
        
        // Filter events to include today through the next 7 days
        filteredEvents = EventManager.shared.events.filter { event in
            // Start of current day
            let startOfDay = calendar.startOfDay(for: currentDate)
            // End of day 7 days from now
            let endOfPeriod = calendar.startOfDay(for: sevenDaysFromNow).addingTimeInterval(86399) // 23:59:59
            
            return event.date >= startOfDay && event.date <= endOfPeriod
        }
        
        // Sort by date
        filteredEvents.sort { $0.date < $1.date }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredEvents.count // Use filtered events instead
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCollectionViewCell
        let event = filteredEvents[indexPath.item] // Use filtered events instead
        cell.configure(with: event)
        return cell
    }
    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedEvent = filteredEvents[indexPath.item] // Get the selected event from filteredEvents
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "EventDetailViewController") as? EventDetailViewController {
            detailVC.event = selectedEvent // Pass the selected event to the detail view controller
            navigationController?.pushViewController(detailVC, animated: true) // Push the detail view controller
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 20
        let height: CGFloat = 100
        return CGSize(width: width, height: height)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = collectionView.frame.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
        pageControl.currentPage = currentPage
    }
    
    private func setupCollectionViewBackground() {
        let messageLabel = UILabel()
        messageLabel.text = "No upcoming events"
        messageLabel.textColor = .gray
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.numberOfLines = 0
        collectionView.backgroundView = messageLabel
        collectionView.backgroundView?.isHidden = !filteredEvents.isEmpty
    }
    
    private func setupCustomNavBar() {
        customNavBarView.translatesAutoresizingMaskIntoConstraints = false
        customNavBarView.backgroundColor = .clear
        view.addSubview(customNavBarView)
        
        let titleLabel = UILabel()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        let currentDate = dateFormatter.string(from: Date())
        titleLabel.text = "\(currentDate) Outfit"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = UIColor(hex: "#978AA7")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        calendarButton = UIButton(type: .system)
        calendarButton.setImage(UIImage(systemName: "calendar"), for: .normal)
        calendarButton.tintColor = UIColor(hex: "#3D3248")
        calendarButton.addTarget(self, action: #selector(calendarButtonTapped), for: .touchUpInside)
        
        profileButton = UIButton(type: .system)
        profileButton.setImage(UIImage(systemName: "person.crop.circle"), for: .normal)
        profileButton.tintColor = UIColor(hex: "#3D3248")
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        
        let iconsStackView = UIStackView(arrangedSubviews: [calendarButton, profileButton])
        iconsStackView.axis = .horizontal
        iconsStackView.spacing = 16
        iconsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let containerStackView = UIStackView(arrangedSubviews: [titleLabel, iconsStackView])
        containerStackView.axis = .horizontal
        containerStackView.spacing = 16
        containerStackView.alignment = .center
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        customNavBarView.addSubview(containerStackView)
        
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
    
    private func setupBackgroundView() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundView, at: 0)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.95, green: 0.92, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.78, green: 0.72, blue: 1.0, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = view.bounds
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @objc override func calendarButtonTapped() {
        print("Calendar button tapped")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let plannerVC = storyboard.instantiateViewController(withIdentifier: "PlannerViewController") as? PlannerViewController {
            navigationController?.pushViewController(plannerVC, animated: true)
        }
    }
    
    @objc override func profileButtonTapped() {
        print("Profile button tapped")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    private func updateGradientLayerFrame() {
        if let gradientLayer = backgroundView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = backgroundView.bounds
        }
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "FitFix"
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(hex: "#554664")
        ]
        
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(hex: "#554664")
        ]
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
    }
    
    
    // Generate Button Action - Connected via Storyboard
    @IBAction func generateOutfit(_ sender: UIButton) {
        fetchClothingData()
        
    }

    private func fetchClothingData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("clothingItems").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            var topItems: [ClothingItem] = []
            var bottomItems: [ClothingItem] = []
            var shoesItems: [ClothingItem] = []
            
            for document in documents {
                if let category = document.data()["category"] as? String,
                   let imageURL = document.data()["imageURL"] as? String {
                    let item = ClothingItem(category: category, imageName: imageURL)
                    
                    switch category {
                    case "Top Wear":
                        topItems.append(item)
                    case "Bottom Wear":
                        bottomItems.append(item)
                    case "Foot Wear":
                        shoesItems.append(item)
                    default:
                        break
                    }
                }
            }
            
            self.selectHarmoniousOutfit(topItems: topItems, bottomItems: bottomItems, shoesItems: shoesItems)
        }
    }

    private func selectHarmoniousOutfit(topItems: [ClothingItem], bottomItems: [ClothingItem], shoesItems: [ClothingItem]) {
            guard !topItems.isEmpty && !bottomItems.isEmpty && !shoesItems.isEmpty else {
                print("No clothing data available")
                DispatchQueue.main.async {
                    self.RecommendedOutfit.image = nil
                    self.noOutfitLabel.isHidden = false
                }
                return
            }
            
            let selectedTop = topItems.randomElement()!
            let selectedBottom = bottomItems.randomElement()!
            let selectedShoes = shoesItems.randomElement()!
            
            generateOutfitImage(top: selectedTop, bottom: selectedBottom, shoes: selectedShoes)
        }
        
        private func generateOutfitImage(top: ClothingItem, bottom: ClothingItem, shoes: ClothingItem) {
            let imageUrls = [top.imageName, bottom.imageName, shoes.imageName]
            
            downloadAndCombineImages(from: imageUrls) { finalImage in
                DispatchQueue.main.async {
                    self.RecommendedOutfit.image = finalImage
                    self.noOutfitLabel.isHidden = true
                }
            }
        }

    private func downloadAndCombineImages(from urls: [String], completion: @escaping (UIImage?) -> Void) {
        var images: [UIImage] = []
        let dispatchGroup = DispatchGroup()
        
        for url in urls {
            dispatchGroup.enter()
            downloadImage(from: url) { image in
                if let image = image {
                    images.append(image)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let combinedImage = self.mergeImages(images: images)
            completion(combinedImage)
        }
    }

    private func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, error == nil, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }

    private func mergeImages(images: [UIImage]) -> UIImage? {
        guard !images.isEmpty else { return nil }
        
        let size = CGSize(width: 300, height: 400)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let sectionHeight = size.height / CGFloat(images.count)
        for (index, image) in images.enumerated() {
            let rect = CGRect(x: 0, y: CGFloat(index) * sectionHeight, width: size.width, height: sectionHeight)
            image.draw(in: rect)
        }
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
    
    // Method to manually show coach marks (can be triggered by a menu option if needed)
    func showCoachMarks() {
        self.coachMarksController.start(in: .window(over: self))
    }
}

extension UIView {
    @discardableResult
    func addBlurEffect(style: UIBlurEffect.Style = .light) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.insertSubview(blurView, at: 0)
        return blurView
    }
}
