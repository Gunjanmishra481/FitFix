import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func StyledButtonClicked(_ sender: UIButton) {
        // Navigate to HomeTabViewController when the button is clicked
        navigateToHomeTabPage()
    }
    
    // Function to navigate to HomeTabViewController
    func navigateToHomeTabPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeTabVC = storyboard.instantiateViewController(withIdentifier: "TabBarHome") as? UITabBarController {
            homeTabVC.modalPresentationStyle = .fullScreen
            self.present(homeTabVC, animated: true, completion: nil)
        }
    }
}
