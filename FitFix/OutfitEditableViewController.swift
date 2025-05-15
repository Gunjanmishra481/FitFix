import UIKit
import FirebaseStorage
import FirebaseAuth

class OutfitEditableViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var bottomImageView: UIImageView!
    @IBOutlet weak var shoesImageView: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var sidebar: UIView!
    @IBOutlet weak var aui: UIView!
    @IBOutlet weak var fui: UIView!
    @IBOutlet weak var jui: UIView!
    @IBOutlet weak var jeans: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var back: UIView!
    
    // MARK: - Properties
    var savedOutfits: [ClothingItem] = []
    static var persistedOutfits: [ClothingItem] = []
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupDefaultOutfit()
        setupCustomBackButton()
        
        
        sidebar.layer.cornerRadius = 14
        sidebar.layer.borderWidth = 1
        sidebar.layer.borderColor = UIColor(hex: "8977BC").cgColor
        sidebar.layer.masksToBounds = true
        sidebar.backgroundColor = .clear
        
        jui.layer.cornerRadius = 14
        jui.layer.borderWidth = 1
        jui.layer.borderColor = UIColor(hex: "8977BC").cgColor
        jui.layer.masksToBounds = true
        jui.backgroundColor = .clear
        
        fui.layer.cornerRadius = 14
        fui.layer.borderWidth = 1
        fui.layer.borderColor = UIColor(hex: "8977BC").cgColor
        fui.layer.masksToBounds = true
        fui.backgroundColor = .clear
        
        aui.layer.cornerRadius = 14
        aui.layer.borderWidth = 1
        aui.layer.borderColor = UIColor(hex: "8977BC").cgColor
        aui.layer.masksToBounds = true
        aui.backgroundColor = .clear
    
             
        back.layer.cornerRadius = 24
        back.clipsToBounds = false
        back.layer.shadowColor = UIColor.black.cgColor
        back.layer.shadowOffset = CGSize(width: 0, height: 0)
        back.layer.shadowOpacity = 0.1
        back.layer.shadowRadius = 5
        
        shareButton.layer.cornerRadius = 10
        shareButton.clipsToBounds = true
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
        
        savedOutfits = OutfitEditableViewController.persistedOutfits
    }
    
    // MARK: - Setup Methods
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.95, green: 0.92, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.78, green: 0.72, blue: 1.0, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = backgroundView.bounds
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupDefaultOutfit() {
        let defaultOutfit = OutfitDataModel.shared.outfitComponents
        headImageView.image = UIImage(named: defaultOutfit[0].imageName)
        topImageView.image = UIImage(named: defaultOutfit[1].imageName)
        bottomImageView.image = UIImage(named: defaultOutfit[2].imageName)
        shoesImageView.image = UIImage(named: defaultOutfit[3].imageName)
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
    
    // MARK: - Screenshot & Toast
    private func captureViewScreenshot(of view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshot
    }
    
    func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 15
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
        
        let padding: CGFloat = 15
        let labelWidth = min(view.frame.width - 80, 250)
        let size = toastLabel.sizeThatFits(CGSize(width: labelWidth, height: .greatestFiniteMagnitude))
        
        // Calculate toast height and new y-position
        let toastHeight = size.height + padding * 2
        let margin: CGFloat = 10 // Space above the safe area
        let yPosition = view.frame.height - view.safeAreaInsets.bottom  - margin
        
        // Set the frame with the adjusted y-position
        toastLabel.frame = CGRect(x: (view.frame.width - labelWidth) / 2,
                                  y: yPosition,
                                  width: labelWidth,
                                  height: toastHeight)
        
        view.addSubview(toastLabel)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            toastLabel.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        })
    }
    
    // MARK: - Category Selection Actions
    @IBAction func TopButtonTapped(_ sender: UIButton) {
        if let clothingVC = storyboard?.instantiateViewController(withIdentifier: "ClothingViewController") as? ClothingViewController {
            clothingVC.selectedCategory = "Top Wear"
            clothingVC.onItemSelected = { [weak self] selectedItem in
                print("Selected top item: \(selectedItem.imageName)")
                self?.loadImageFromFirebase(urlString: selectedItem.imageName, into: self?.topImageView)
            }
            navigationController?.pushViewController(clothingVC, animated: true)
        }
    }

    
    @IBAction func BottomButtonTapped(_ sender: UIButton) {
        if let clothingVC = storyboard?.instantiateViewController(withIdentifier: "ClothingViewController") as? ClothingViewController {
            clothingVC.selectedCategory = "Bottom Wear"
            clothingVC.onItemSelected = { [weak self] selectedItem in
                print("Selected bottom item: \(selectedItem.imageName)")
                self?.loadImageFromFirebase(urlString: selectedItem.imageName, into: self?.bottomImageView)
            }
            navigationController?.pushViewController(clothingVC, animated: true)
        }
    }

    
    @IBAction func ShoesButtonTapped(_ sender: UIButton) {
        if let clothingVC = storyboard?.instantiateViewController(withIdentifier: "ClothingViewController") as? ClothingViewController {
            clothingVC.selectedCategory = "Foot Wear"
            clothingVC.onItemSelected = { [weak self] selectedItem in
                print("Selected shoes item: \(selectedItem.imageName)")
                self?.loadImageFromFirebase(urlString: selectedItem.imageName, into: self?.shoesImageView)
            }
            navigationController?.pushViewController(clothingVC, animated: true)
        }
    }

    
    @IBAction func AccessoriesButtonTapped(_ sender: UIButton) {
        if let clothingVC = storyboard?.instantiateViewController(withIdentifier: "ClothingViewController") as? ClothingViewController {
            clothingVC.selectedCategory = "Accessories"
            clothingVC.onItemSelected = { [weak self] selectedItem in
                print("Selected accessory item: \(selectedItem.imageName)")
                self?.loadImageFromFirebase(urlString: selectedItem.imageName, into: self?.headImageView)
            }
            navigationController?.pushViewController(clothingVC, animated: true)
        }
    }

    private func loadImageFromFirebase(urlString: String, into imageView: UIImageView?) {
        guard let url = URL(string: urlString) else {
            print("Invalid image URL: \(urlString)")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error.localizedDescription)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView?.image = image
                }
            }
        }.resume()
    }

    // MARK: - Firebase Storage Upload
    func uploadImageToStorage(_ image: UIImage, completion: @escaping (String?, Error?) -> Void) {
        let storageRef = Storage.storage().reference().child("outfitScreenshots/\(UUID().uuidString).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil, NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"]))
            return
        }
        
        let uploadTask = storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Upload failed: \(error.localizedDescription)")
                completion(nil, error)
            } else {
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Failed to get download URL: \(error.localizedDescription)")
                        completion(nil, error)
                    } else if let downloadURL = url {
                        completion(downloadURL.absoluteString, nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Save Action
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let screenshot = captureViewScreenshot(of: back) else {
            let alert = UIAlertController(title: "Error", message: "Failed to capture outfit.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Show loading animation
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
        uploadImageToStorage(screenshot) { [weak self] (imageURL, error) in
            guard let self = self else { return }
            
            // Remove loading indicator
            DispatchQueue.main.async {
                loadingIndicator.stopAnimating()
                loadingIndicator.removeFromSuperview()
            }
            
            if let error = error {
                let alert = UIAlertController(title: "Error", message: "Failed to upload image: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            } else if let imageURL = imageURL {
                let savedItem = ClothingItem(category: "Outfit", imageName: imageURL, firebaseID: nil)
                self.savedOutfits.append(savedItem)
                OutfitEditableViewController.persistedOutfits.append(savedItem)
                
                let feedbackGenerator = UINotificationFeedbackGenerator()
                feedbackGenerator.notificationOccurred(.success)
                
                // Show toast message
                DispatchQueue.main.async {
                    self.showToast(message: "Outfit saved")
                }
            }
        }
    }

    
    // MARK: - Share Action
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        guard let screenshot = captureViewScreenshot(of: back) else {
            showToast(message: "Failed to capture outfit.")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [screenshot], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = sender
        present(activityVC, animated: true, completion: nil)
    }
}

