
import UIKit

class EventDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var DisplayView: UIView!
    var event: Event? // Property to receive the event

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        // Set up UI with event data
        if let event = event {
                    titleLabel.text = event.title
                    eventImageView.image = event.displayImage
                }
        setupCustomBackButton()
        styleDisplayView()
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
    private func styleDisplayView() {
                // Add rounded corners
        
        DisplayView.layer.cornerRadius = 15 // Adjust as needed
        DisplayView.layer.masksToBounds = false // Ensures shadow isn't clipped

                // Add shadow
        DisplayView.layer.shadowColor = UIColor.black.cgColor
        DisplayView.layer.shadowOpacity = 0.2 // Adjust opacity (0.0 to 1.0)
        DisplayView.layer.shadowOffset = CGSize(width: 0, height: 2) // Adjust shadow direction
        DisplayView.layer.shadowRadius = 4 // Adjust shadow blur
                
                // Add border (optional)
        DisplayView.layer.borderColor = UIColor.lightGray.cgColor
    }
}
