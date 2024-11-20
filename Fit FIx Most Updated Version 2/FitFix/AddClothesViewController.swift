import UIKit

class AddClothesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var optionsTableView: UITableView!
    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var selectedImageView: UIImageView! // UIImageView to display selected image
    
    let addItems = ["Take Photo                >", "Choose From Library           >"]
    var categories = ["Tops", "Bottoms", "Shoes", "Accessories"]
    var selectedImage: UIImage? = nil // Holds the uploaded image temporarily
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        optionsTableView.dataSource = self
        optionsTableView.delegate = self
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == optionsTableView {
            return addItems.count
        } else if tableView == categoriesTableView {
            return categories.count // Includes dynamically added categories
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == optionsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddItemCell", for: indexPath) as! AddItemTableViewCell
            cell.titleLabel.text = addItems[indexPath.row]
            return cell
        } else if tableView == categoriesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
            cell.textLabel?.text = categories[indexPath.row] // Display dynamically added categories
            return cell
        }
        return UITableViewCell() // Return an empty cell if it doesn't match any table view
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if tableView == optionsTableView {
            if indexPath.row == 0 {
                openCamera()
            } else if indexPath.row == 1 {
                openPhotoLibrary()
            }
        } else if tableView == categoriesTableView {
            let selectedCategory = categories[indexPath.row] // Get the selected category
            if let image = selectedImage {
                addImageToCategory(category: selectedCategory, image: image)
                selectedImage = nil
                selectedImageView.image = nil // Clear the image view after adding
                showAlert(message: "Image added to \(selectedCategory)!")
            } else {
                showAlert(message: "Please upload an image first.")
            }
        }
    }

    // Open Camera
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            showAlert(message: "Camera not available.")
        }
    }
    
    // Open Photo Library
    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            showAlert(message: "Photo Library not available.")
        }
    }

    // UIImagePickerController Delegate Method for handling image selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            selectedImageView.image = editedImage // Display the selected image in the image view
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Add image to the selected category
    func addImageToCategory(category: String, image: UIImage) {
        switch category {
        case "Shoes":
            ShoesData.items.append(ClothingItem(category: category, imageName: image))
        case "Accessories":
            AccessoriesData.items.append(ClothingItem(category: category, imageName: image))
        case "Tops":
            ClothingData.items.append(ClothingItem(category: category, imageName: image))
        case "Bottoms":
            BottomsData.items.append(ClothingItem(category: category, imageName: image))
        default:
            // Handle new dynamic category (You may store this dynamically in a data structure)
            let newCategoryData = ClothingItem(category: category, imageName: image)
            // Add logic to save this dynamically if needed
            print("Add image for new category: \(category)")
        }
    }

    // Show alert messages
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Function to show the add category alert
    func showAddCategoryAlert() {
        let alertController = UIAlertController(title: "New Category", message: "Enter category name", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Category Name"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let name = alertController.textFields?.first?.text, !name.isEmpty else { return }
            self?.categories.append(name) // Add the new category to the array
            self?.categoriesTableView.reloadData() // Refresh the categories table view
        }
        
        alertController.addAction(addAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    // Button action to trigger the add category alert
    @IBAction func addCategoryButtonPressed(_ sender: UIButton) {
        showAddCategoryAlert()
    }
}
