import UIKit

class CategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    var categories: [Category] = DataModel.categories // Categories with predefined data

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = generateLayout() // Apply the custom layout
    }

    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 20 // Edge spacing
        layout.itemSize = CGSize(width: 170, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 16, left: spacing, bottom: 16, right: spacing)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 10
        return layout
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count + 1 // +1 for "Add Category" cell
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == categories.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddCategoryCell", for: indexPath)
            // Customize "Add Category" cell if needed
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            let category = categories[indexPath.item]
            cell.label.text = category.name
            cell.count.text = "\(category.Count)"
            return cell
        }
    }

    func showAddCategoryAlert() {
        let alertController = UIAlertController(title: "New Category", message: "Enter category name", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Category Name"
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let name = alertController.textFields?.first?.text, !name.isEmpty else { return }
            let newCategory = Category(id: UUID(), name: name, iconName: "plus", Count: 0)
            self?.categories.append(newCategory)
            self?.collectionView.reloadData()
        }
        alertController.addAction(addAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == categories.count {
            showAddCategoryAlert() // Add new category
        } else {
            let selectedCategory = categories[indexPath.item]
            navigateToClothingVC(category: selectedCategory.name)
        }
    }

    private func navigateToClothingVC(category: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var viewController: UIViewController?

        switch category {
        case "Top Wear":
            viewController = storyboard.instantiateViewController(withIdentifier: "ClothingViewController") as? ClothingViewController
        case "Bottom Wear":
            viewController = storyboard.instantiateViewController(withIdentifier: "BottomsViewController") as? BottomsViewController
        case "Foot Wear":
            viewController = storyboard.instantiateViewController(withIdentifier: "ShoesViewController") as? ShoesViewController
        case "Accessories":
            viewController = storyboard.instantiateViewController(withIdentifier: "AccessoriesViewController") as? AccessoriesViewController
        default:
            let newCategoryVC = UIViewController()
            newCategoryVC.view.backgroundColor = .white
            newCategoryVC.title = category
            let label = UILabel()
            label.text = "\(category) is Empty"
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 24)
            label.translatesAutoresizingMaskIntoConstraints = false
            newCategoryVC.view.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: newCategoryVC.view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: newCategoryVC.view.centerYAnchor)
            ])
            viewController = newCategoryVC
        }

        if let viewController = viewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
