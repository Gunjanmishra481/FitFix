import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGradientBackground()
    }
    @IBOutlet weak var getStyled: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBAction func StyledButtonClicked(_ sender: UIButton) {
        // Navigate to HomeTabViewController when the button is clicked
        navigateToHomeTabPage()
    }
    private func setupUI() {
        // Setup corner radius for text fields
        getStyled.layer.cornerRadius = 12
        getStyled.clipsToBounds = true
    }
    // Function to navigate to HomeTabViewController
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
    func navigateToHomeTabPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeTabVC = storyboard.instantiateViewController(withIdentifier: "TabBarHome") as? UITabBarController {
            homeTabVC.modalPresentationStyle = .fullScreen
            self.present(homeTabVC, animated: true, completion: nil)
        }
    }
}
