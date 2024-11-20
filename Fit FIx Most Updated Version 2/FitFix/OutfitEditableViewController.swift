import UIKit

class OutfitEditableViewController: UIViewController {
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var bottomImageView: UIImageView!
    @IBOutlet weak var shoesImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultOutfit()
        setupCustomBackButton()
    }

    private func setupCustomBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(handleBack))
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
        navigationController?.navigationBar.tintColor = .black
    }
    
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        // Capture the screenshot of the screen
        guard let screenshot = captureScreenshot() else {
            let alert = UIAlertController(title: "Error", message: "Failed to capture screenshot.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Share the captured screenshot
        let activityVC = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sender // For iPad compatibility
        present(activityVC, animated: true)
    }

    // Function to capture a screenshot of the current screen
    private func captureScreenshot() -> UIImage? {
        // Start a new graphics context
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        
        // Render the view hierarchy into the context
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        
        // Capture the image from the context
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the graphics context
        UIGraphicsEndImageContext()
        
        return screenshot
    }



    
        

    // Action for Top Button
    @IBAction func TopButtonTapped(_ sender: UIButton) {
        let clothingVC = storyboard?.instantiateViewController(withIdentifier: "ClothingViewController") as! ClothingViewController
        clothingVC.onItemSelected = { [weak self] selectedItem in
            // Directly assign the UIImage
            self?.topImageView.image = selectedItem.imageName
        }
        navigationController?.pushViewController(clothingVC, animated: true)
    }

    // Action for Bottom Button
    @IBAction func BottomButtonTapped(_ sender: UIButton) {
        let bottomsVC = storyboard?.instantiateViewController(withIdentifier: "BottomsViewController") as! BottomsViewController
        bottomsVC.onItemSelected = { [weak self] selectedItem in
            self?.bottomImageView.image = selectedItem.imageName
        }
        navigationController?.pushViewController(bottomsVC, animated: true)
    }

    // Action for Shoes Button
    @IBAction func ShoesButtonTapped(_ sender: UIButton) {
        let shoesVC = storyboard?.instantiateViewController(withIdentifier: "ShoesViewController") as! ShoesViewController
        shoesVC.onItemSelected = { [weak self] selectedItem in
            self?.shoesImageView.image = selectedItem.imageName
        }
        navigationController?.pushViewController(shoesVC, animated: true)
    }

    // Action for Accessories Button
    @IBAction func AccessoriesButtonTapped(_ sender: UIButton) {
        let accessoriesVC = storyboard?.instantiateViewController(withIdentifier: "AccessoriesViewController") as! AccessoriesViewController
        accessoriesVC.onItemSelected = { [weak self] selectedItem in
            self?.headImageView.image = selectedItem.imageName
        }
        navigationController?.pushViewController(accessoriesVC, animated: true)
    }

    private func setupDefaultOutfit() {
        // Load default outfit images
        headImageView.image = UIImage(named: outfitItems[0].imageName)
        topImageView.image = UIImage(named: outfitItems[1].imageName)
        bottomImageView.image = UIImage(named: outfitItems[2].imageName)
        shoesImageView.image = UIImage(named: outfitItems[3].imageName)
    }
}
