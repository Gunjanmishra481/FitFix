import UIKit


class HomeTabViewController: UICollectionViewController, CoachMarksControllerDelegate, CoachMarksControllerDataSource, CoachMarksControllerAnimationDelegate {
    
    // MARK: - Properties
    private let coachMarksController = CoachMarksController()
    private let customNavBarView = UIView()
    private let backgroundView = UIView()
    private var calendarButton: UIButton!
    private var profileButton: UIButton!
    
    private let coachMarksCompletedKey = "HasCompletedCoachMarks"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundView()
        setupCustomNavBar()
        setupCoachMarks()
        setupCollectionView()
        
        UserDefaults.standard.removeObject(forKey: coachMarksCompletedKey)
        setupNavigationBar()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updateGradientLayerFrame()
        }
    }
    
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "FitFix"

        // Change title color for normal size
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(hex: "#554664")
        ]

        // Change title color for large titles
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(hex: "#554664")
        ]

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
    }
    
    private func setupCollectionView() {
        // Configure collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = false
        collectionView.decelerationRate = .fast  // Makes the carousel snap better
        
        // Create proper carousel layout
        let layout = createCarouselLayout()
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        // Register cell tap handling
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCellTap(_:)))
        collectionView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateGradientLayerFrame()
        
        // Only show coach marks if they haven't been shown before
        if !UserDefaults.standard.bool(forKey: coachMarksCompletedKey) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.view.layoutIfNeeded()
                self.startCoachMarks()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop coach marks when leaving the view
        coachMarksController.stop(immediately: true)
    }
    
    // MARK: - Carousel Layout
    private func createCarouselLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            // Item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            // Group - REDUCED WIDTH from 0.85 to 0.7
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.75),  // Reduced width here
                heightDimension: .fractionalHeight(0.77)  // Slightly reduced height to maintain proportions
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.interGroupSpacing = 12  // Adjusted spacing to complement narrower width
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
            
            // Add snap-to-center behavior
            section.visibleItemsInvalidationHandler = { items, offset, environment in
                items.forEach { item in
                    let distanceFromCenter = abs((item.frame.midX - offset.x) - environment.container.contentSize.width / 2.0)
                    let scale = max(0.88, 1 - distanceFromCenter / environment.container.contentSize.width)
                    item.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
            
            return section
        }
        return layout
    }
    
    // MARK: - Cell Tap Handling
    
    @objc private func handleCellTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            collectionView(collectionView, didSelectItemAt: indexPath)
        }
    }
    
    // MARK: - UICollectionView DataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return OutfitDataModel.shared.outfitItems.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OutfitCell", for: indexPath) as! OutfitCollectionViewCell
        let outfitItem = OutfitDataModel.shared.outfitItems[indexPath.row]
        
        // Configure cell appearance
        cell.outfitImageView.image = UIImage(named: outfitItem.imageName)
        configureCardAppearance(for: cell)
        
        return cell
    }
    
    private func configureCardAppearance(for cell: UICollectionViewCell) {
        cell.layer.cornerRadius = 20
        cell.backgroundColor = UIColor(hex: "#F7F2FF")
        
        // Enhanced shadow effect
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 8.0
        cell.layer.shadowOpacity = 0.2
        cell.layer.masksToBounds = false
    }
    
    // MARK: - UICollectionView Delegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle navigation based on selected outfit
        let outfitItem = OutfitDataModel.shared.outfitItems[indexPath.row]
        navigateToDetail(for: outfitItem)
    }
    
    private func navigateToDetail(for outfitItem: OutfitItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "OutfitEditableViewController") as? OutfitEditableViewController {
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    // MARK: - Background and Layout Setup
    
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
            UIColor(red: 0.85, green: 0.80, blue: 1.0, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = view.bounds
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func updateGradientLayerFrame() {
        if let gradientLayer = backgroundView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = backgroundView.bounds
        }
    }
    
    private func setupCustomNavBar() {
        customNavBarView.translatesAutoresizingMaskIntoConstraints = false
        customNavBarView.backgroundColor = .clear
        view.addSubview(customNavBarView)
        
        let titleLabel = UILabel()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM" // Formats like "9 March"
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
        
        // Adjust the collection view's constraints so it appears below the custom navigation bar.
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: customNavBarView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Button Actions
    
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
    
    // MARK: - Coach Marks Setup
    
    private func setupCoachMarks() {
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        
        coachMarksController.overlay.isUserInteractionEnabled = true
        
        coachMarksController.overlay.backgroundColor = UIColor(white: 0.0, alpha: 0.65)
        
        let skipView = CoachMarkSkipDefaultView()
        skipView.setTitle("Skip Tour", for: .normal)
        skipView.setTitleColor(UIColor(hex: "#554664"), for: .normal)
        coachMarksController.skipView = skipView
        coachMarksController.animationDelegate = self
    }
    
    private func startCoachMarks() {
        // Add this line before starting coach marks
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
        
        // Then start coach marks
        coachMarksController.start(in: .window(over: self))
    }
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool) {
        // Mark coach marks as completed when finished or skipped
        UserDefaults.standard.set(true, forKey: coachMarksCompletedKey)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingAt index: Int) {
        if index == numberOfCoachMarks(for: coachMarksController) - 1 {
            // Mark coach marks as completed when all steps are done
            UserDefaults.standard.set(true, forKey: coachMarksCompletedKey)
        }
    }
    
    // MARK: - Coach Marks Data Source
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 3
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        var coachMark: CoachMark
        
        switch index {
        case 0:
            coachMark = coachMarksController.helper.makeCoachMark(
                for: calendarButton,
                cutoutPathMaker: { frame -> UIBezierPath in
                    return UIBezierPath(ovalIn: frame)
                }
            )
        case 1:
            // Get the first cell specifically by index path
            if let firstCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) {
                coachMark = coachMarksController.helper.makeCoachMark(
                    for: firstCell,
                    cutoutPathMaker: { frame -> UIBezierPath in
                        return UIBezierPath(roundedRect: frame, cornerRadius: 20)
                    }
                )
            } else {
                // If first cell is not loaded yet, you could try to scroll then get it
                collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
                collectionView.layoutIfNeeded()
                
                // Try again after forcing layout
                if let firstCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) {
                    coachMark = coachMarksController.helper.makeCoachMark(
                        for: firstCell,
                        cutoutPathMaker: { frame -> UIBezierPath in
                            return UIBezierPath(roundedRect: frame, cornerRadius: 20)
                        }
                    )
                }
                else {
                    // Fallback if still can't get the cell
                    coachMark = coachMarksController.helper.makeCoachMark(for: view)
                }
            }
        case 2:
            guard let tabBar = tabBarController?.tabBar,
                  let tabBarButtons = tabBar.subviews
                    .filter({ $0.description.contains("UITabBarButton") })
                    .sorted(by: { $0.frame.origin.x < $1.frame.origin.x })
                    .get(1) else {
                return coachMarksController.helper.makeCoachMark(for: view)
            }
            
            coachMark = coachMarksController.helper.makeCoachMark(
                for: tabBarButtons,
                cutoutPathMaker: { frame -> UIBezierPath in
                    return UIBezierPath(roundedRect: frame, cornerRadius: 8)
                }
            )
            coachMark.arrowOrientation = .bottom
        default:
            coachMark = coachMarksController.helper.makeCoachMark(for: view)
        }
        
        coachMark.maxWidth = 300
        return coachMark
    }
    
    class BlockingView: UIView {
        // Override hitTest to always return self so that all touches are captured.
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            return self
        }
    }

    func coachMarksController(
           _ coachMarksController: CoachMarksController,
           coachMarkViewsAt index: Int,
           madeFrom coachMark: CoachMark
       ) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
           
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(
            withArrow: true,
            arrowOrientation: coachMark.arrowOrientation
        )
           coachViews.bodyView.layer.cornerRadius = 12
           coachViews.bodyView.clipsToBounds = true
        // Utility to get the key window on iOS 15 and later.
        func getKeyWindow() -> UIWindow? {
            // First try the window from bodyView if available.
            if let window = coachViews.bodyView.window {
                return window
            }
            
            // Fallback: iterate through connected scenes.
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .first(where: { $0.isKeyWindow })
        }

        
        coachViews.bodyView.backgroundColor = UIColor(hex: "#F7F2FF")
        coachViews.bodyView.hintLabel.textColor = UIColor(hex: "#554664")
        coachViews.bodyView.nextLabel.textColor = UIColor(hex: "#978AA7")
        
        switch index {
        case 0:
            coachViews.bodyView.hintLabel.text = "Access your calendar to plan your outfits"
            coachViews.bodyView.nextLabel.text = "Next"
        case 1:
            coachViews.bodyView.hintLabel.text = "Swipe through your outfit cards to see recommendations"
            coachViews.bodyView.nextLabel.text = "Next"
            
            // Use the utility to get the current key window.
            let window = getKeyWindow()
            
            // Define a tag for the touch indicator so it can be removed later if needed.
            let touchIndicatorTag = 999
            
            // Remove any previous touch indicator if it exists.
            if let existingIndicator = window?.viewWithTag(touchIndicatorTag) {
                existingIndicator.removeFromSuperview()
            }
            
            // Create a container view for the touch indicator (containing the circle and ripple)
            let touchIndicatorContainer = UIView()
            touchIndicatorContainer.translatesAutoresizingMaskIntoConstraints = false
            touchIndicatorContainer.tag = touchIndicatorTag
            
            // Create the main touch point circle
            let touchCircle = UIView()
            touchCircle.translatesAutoresizingMaskIntoConstraints = false
            touchCircle.backgroundColor = UIColor(hex: "#3D3248").withAlphaComponent(0.5)
            touchCircle.layer.cornerRadius = 15 // Making it a circle
            
            // Create the outer ripple circle
            let rippleCircle = UIView()
            rippleCircle.translatesAutoresizingMaskIntoConstraints = false
            rippleCircle.backgroundColor = UIColor.clear
            rippleCircle.layer.borderWidth = 2
            rippleCircle.layer.borderColor = UIColor(hex: "#3D3248").withAlphaComponent(1).cgColor
            rippleCircle.layer.cornerRadius = 25 // Larger than the inner circle
            
            // Add the circles to the container
            touchIndicatorContainer.addSubview(rippleCircle)
            touchIndicatorContainer.addSubview(touchCircle)
            
            // Add the container to the window or fallback to coachViews
            if let window = window {
                window.addSubview(touchIndicatorContainer)
                window.bringSubviewToFront(touchIndicatorContainer)
            } else {
                coachViews.bodyView.addSubview(touchIndicatorContainer)
            }
            
            // Set the initial opacity
            touchIndicatorContainer.alpha = 0.7
            
            // Layout constraints for the touch indicator container
            NSLayoutConstraint.activate([
                // Position in the middle of the screen vertically
                touchIndicatorContainer.centerYAnchor.constraint(equalTo: (window ?? coachViews.bodyView).centerYAnchor),
                touchIndicatorContainer.leadingAnchor.constraint(equalTo: (window ?? coachViews.bodyView).leadingAnchor, constant: 20),
                touchIndicatorContainer.widthAnchor.constraint(equalToConstant: 50),
                touchIndicatorContainer.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            // Constraints for the inner touch circle
            NSLayoutConstraint.activate([
                touchCircle.centerXAnchor.constraint(equalTo: touchIndicatorContainer.centerXAnchor),
                touchCircle.centerYAnchor.constraint(equalTo: touchIndicatorContainer.centerYAnchor),
                touchCircle.widthAnchor.constraint(equalToConstant: 30),
                touchCircle.heightAnchor.constraint(equalToConstant: 30)
            ])
            
            // Constraints for the ripple circle
            NSLayoutConstraint.activate([
                rippleCircle.centerXAnchor.constraint(equalTo: touchIndicatorContainer.centerXAnchor),
                rippleCircle.centerYAnchor.constraint(equalTo: touchIndicatorContainer.centerYAnchor),
                rippleCircle.widthAnchor.constraint(equalToConstant: 50),
                rippleCircle.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            // Reduce the travel distance by using a smaller percentage of screen width
            let animationDistance = UIScreen.main.bounds.width - 84 // 40% of screen width
            touchIndicatorContainer.transform = CGAffineTransform(translationX: animationDistance, y: 0)
            
            // The number of times the animation should run
            var remainingAnimations = 2
            
            func animateRipple() {
                UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
                    rippleCircle.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                })
            }
            
            func animateTouchIndicator() {
                guard remainingAnimations > 0 else {
                    // All iterations complete; fade out the indicator
                    UIView.animate(withDuration: 1.0, animations: {
                        touchIndicatorContainer.alpha = 0.0
                    }, completion: { _ in
                        // Stop ripple animation when fading out
                        rippleCircle.layer.removeAllAnimations()
                    })
                    return
                }
                
                UIView.animate(withDuration: 2.0, delay: 0.5, options: [.curveEaseInOut], animations: {
                    // Animate the touch indicator from right to left
                    touchIndicatorContainer.transform = CGAffineTransform.identity
                }, completion: { finished in
                    if finished {
                        // Add a small delay at the end of each swipe to simulate a tap
                        UIView.animate(withDuration: 0.2, animations: {
                            touchCircle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                        }, completion: { _ in
                            UIView.animate(withDuration: 0.2, animations: {
                                touchCircle.transform = CGAffineTransform.identity
                            }, completion: { _ in
                                // Reset the indicator position to the starting point on the right
                                touchIndicatorContainer.transform = CGAffineTransform(translationX: animationDistance, y: 0)
                                
                                // Decrement the counter and call animateTouchIndicator again
                                remainingAnimations -= 1
                                animateTouchIndicator()
                            })
                        })
                    }
                })
            }
            
            // Start the ripple animation
            animateRipple()
            
            // Start the touch indicator animation sequence
            animateTouchIndicator()
        case 2:
            coachViews.bodyView.hintLabel.text = "Tap here to access more features!"
            coachViews.bodyView.nextLabel.text = "Got it!"
            
            if let arrowView = coachViews.arrowView {
                arrowView.backgroundColor = .clear
                
                UIView.animate(withDuration: 1.0,
                              delay: 0,
                              options: [.repeat, .autoreverse, .curveEaseInOut],
                              animations: {
                    arrowView.transform = CGAffineTransform(translationX: 0, y: -10)
                }) { _ in
                    arrowView.transform = .identity
                }
            }
        default:
            break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}

// MARK: - CoachMarksController Animation Delegate
extension HomeTabViewController {
    func coachMarksController(
        _ coachMarksController: CoachMarksController,
        fetchAppearanceTransitionOfCoachMark coachMarkView: UIView,
        at index: Int,
        using manager: CoachMarkTransitionManager
    ) {
        if index == 4 { // For tab bar button
            manager.parameters.duration = 0.75
            manager.parameters.options = [.curveEaseInOut]
        }
    }
}

// MARK: - Array Extension
extension Array {
    func get(_ index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}
