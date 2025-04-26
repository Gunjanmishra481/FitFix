import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import CoreImage

// MARK: - Notification Names

extension Notification.Name {
    static let categoriesDidChange = Notification.Name("categoriesDidChange")
    static let clothingItemsDidChange = Notification.Name("clothingItemsDidChange")
}

// MARK: - Category Models

struct Category {
    let id: UUID
    var name: String
    var iconName: String
    var count: Int
    var firebaseID: String?
}

class CategoryManager {
    static let shared = CategoryManager()
    private init() {
        // Set up default categories
        self.categories = [
            Category(id: UUID(), name: "Top Wear", iconName: "shirt", count: 0, firebaseID: "topWear"),
            Category(id: UUID(), name: "Bottom Wear", iconName: "pants", count: 0, firebaseID: "bottomWear"),
            Category(id: UUID(), name: "Foot Wear", iconName: "shoes", count: 0, firebaseID: "footWear"),
            Category(id: UUID(), name: "Accessories", iconName: "hat", count: 0, firebaseID: "accessories")
        ]
        
        // Add observer for clothing item changes
        NotificationCenter.default.addObserver(self, selector: #selector(updateCategoryCounts), name: .clothingItemsDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var categories: [Category] = [] {
        didSet {
            NotificationCenter.default.post(name: .categoriesDidChange, object: nil)
        }
    }
    
    @objc func updateCategoryCounts() {
        // Update counts based on the current items
        var updatedCategories = categories
        
        for (index, category) in categories.enumerated() {
            let count = ClothingData.items.filter { $0.category == category.name }.count
            updatedCategories[index] = Category(
                id: category.id,
                name: category.name,
                iconName: category.iconName,
                count: count,
                firebaseID: category.firebaseID
            )
        }
        
        self.categories = updatedCategories
    }
    
    // Fetch categories from the current user's subcollection
    func fetchCategories(completion: @escaping ([Category]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No logged in user found.")
            completion(self.categories)
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .collection("categories")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching categories: \(error)")
                    completion(self.categories)
                } else {
                    let fetchedCategories = querySnapshot?.documents.compactMap { doc -> Category? in
                        let data = doc.data()
                        return Category(
                            id: UUID(),
                            name: data["name"] as? String ?? "",
                            iconName: data["iconName"] as? String ?? "",
                            count: data["count"] as? Int ?? 0,
                            firebaseID: doc.documentID
                        )
                    } ?? []

                    // Merge default categories with fetched categories
                    var mergedCategories = self.categories
                    for fetchedCategory in fetchedCategories {
                        if let index = mergedCategories.firstIndex(where: { $0.firebaseID == fetchedCategory.firebaseID }) {
                            // Update existing category
                            mergedCategories[index] = fetchedCategory
                        } else {
                            // Add new category if not in default list
                            mergedCategories.append(fetchedCategory)
                        }
                    }
                    self.categories = mergedCategories
                    
                    // Update counts after fetching categories
                    self.updateCategoryCounts()
                    
                    completion(self.categories)
                }
            }
    }
}

// MARK: - Clothing Models

struct ClothingItem {
    let category: String
    let imageName: String // Firebase URL
    var firebaseID: String?
}

struct ClothingData {
    static var items: [ClothingItem] = []
    
    /// Fetch clothing items from the current user's subcollection
    static func fetchClothingItems(completion: @escaping ([ClothingItem]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No logged in user found.")
            completion([])
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .collection("clothingItems")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching clothing items: \(error)")
                    completion([])
                } else {
                    items = querySnapshot?.documents.compactMap { doc -> ClothingItem? in
                        let data = doc.data()
                        return ClothingItem(
                            category: data["category"] as? String ?? "",
                            imageName: data["imageURL"] as? String ?? "",
                            firebaseID: doc.documentID
                        )
                    } ?? []
                    
                    // Update category counts after fetching items
                    NotificationCenter.default.post(name: .clothingItemsDidChange, object: nil)
                    
                    completion(items)
                }
            }
    }
    
    /// Delete a clothing item from Firebase
    static func deleteClothingItem(item: ClothingItem, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid,
              let firebaseID = item.firebaseID else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        // Delete from Firestore
        db.collection("users").document(userId).collection("clothingItems").document(firebaseID).delete { error in
            if let error = error {
                print("Error deleting document: \(error)")
                completion(false)
                return
            }
            
            // Delete from Storage if it's a URL
            if let imageURL = URL(string: item.imageName) {
                // Extract the path from the URL (assuming Firebase Storage URL format)
                let path = imageURL.lastPathComponent
                let storageRef = storage.reference().child("users/\(userId)/images/\(path)")
                
                storageRef.delete { error in
                    if let error = error {
                        print("Error deleting image: \(error)")
                        completion(false)
                    } else {
                        print("Image deleted successfully")
                        
                        // Remove from local array
                        if let index = items.firstIndex(where: { $0.firebaseID == item.firebaseID }) {
                            items.remove(at: index)
                        }
                        
                        // Notify about the change
                        NotificationCenter.default.post(name: .clothingItemsDidChange, object: nil)
                        
                        completion(true)
                    }
                }
            } else {
                // If no image URL, just complete the operation
                // Remove from local array
                if let index = items.firstIndex(where: { $0.firebaseID == item.firebaseID }) {
                    items.remove(at: index)
                }
                
                // Notify about the change
                NotificationCenter.default.post(name: .clothingItemsDidChange, object: nil)
                
                completion(true)
            }
        }
    }
}

// MARK: - Outfit Models
struct OutfitItem {
    let imageName: String
    let category: String
    let imageURL: String
}

class OutfitDataModel {
    static let shared = OutfitDataModel()
    
    var outfitItems: [OutfitItem] = []
    var outfitComponents: [OutfitItem] = [
        OutfitItem(imageName: "head", category: "Head", imageURL: ""),
        OutfitItem(imageName: "top", category: "Top Wear", imageURL: ""),
        OutfitItem(imageName: "bottom", category: "Bottom Wear", imageURL: ""),
        OutfitItem(imageName: "shoes", category: "Foot Wear", imageURL: "")
    ]
    
    // Fetch clothing items from Firebase Firestore
    func fetchClothingItems(completion: @escaping ([OutfitItem]) -> Void) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion([])
            return
        }
        
        db.collection("users").document(userId).collection("clothingItems").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching clothing items: \(error)")
                completion([])
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No clothing items found")
                completion([])
                return
            }
            
            var clothingItems: [OutfitItem] = []
            for document in documents {
                let data = document.data()
                if let imageURL = data["imageURL"] as? String,
                   let category = data["category"] as? String {
                    let outfitItem = OutfitItem(imageName: document.documentID, category: category, imageURL: imageURL)
                    clothingItems.append(outfitItem)
                }
            }
            
            completion(clothingItems)
        }
    }
    
    // Generate an outfit with harmonious colors
    func generateOutfit(completion: @escaping (UIImage?) -> Void) {
        fetchClothingItems { clothingItems in
            // Filter items by category
            let topItems = clothingItems.filter { $0.category == "Top Wear" }
            let bottomItems = clothingItems.filter { $0.category == "Bottom Wear" }
            let shoesItems = clothingItems.filter { $0.category == "Foot Wear" }
            
            // Ensure we have at least one item in each category
            guard !topItems.isEmpty, !bottomItems.isEmpty, !shoesItems.isEmpty else {
                print("Not enough items in one or more categories")
                completion(nil)
                return
            }
            
            // Randomly select one item from each category (for simplicity)
            let topItem = topItems.randomElement()!
            let bottomItem = bottomItems.randomElement()!
            let shoesItem = shoesItems.randomElement()!
            
            // Download images from Firebase Storage
            self.downloadImages(top: topItem, bottom: bottomItem, shoes: shoesItem) { topImage, bottomImage, shoesImage in
                guard let topImage = topImage, let bottomImage = bottomImage, let shoesImage = shoesImage else {
                    print("Failed to download one or more images")
                    completion(nil)
                    return
                }
                
                // Combine images into a single outfit
                let combinedImage = self.combineOutfitImages(top: topImage, bottom: bottomImage, shoes: shoesImage)
                completion(combinedImage)
            }
        }
    }
    
    // Download images from Firebase Storage
    private func downloadImages(top: OutfitItem, bottom: OutfitItem, shoes: OutfitItem, completion: @escaping (UIImage?, UIImage?, UIImage?) -> Void) {
        let storage = Storage.storage()
        let dispatchGroup = DispatchGroup()
        var topImage: UIImage?
        var bottomImage: UIImage?
        var shoesImage: UIImage?
        
        dispatchGroup.enter()
        storage.reference(forURL: top.imageURL).getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let data = data, let image = UIImage(data: data) {
                topImage = image
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        storage.reference(forURL: bottom.imageURL).getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let data = data, let image = UIImage(data: data) {
                bottomImage = image
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        storage.reference(forURL: shoes.imageURL).getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let data = data, let image = UIImage(data: data) {
                shoesImage = image
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(topImage, bottomImage, shoesImage)
        }
    }
    
    // Combine images into a single outfit image
    private func combineOutfitImages(top: UIImage, bottom: UIImage, shoes: UIImage) -> UIImage? {
        let canvasSize = CGSize(width: 300, height: 450)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0.0)
        
        let topRect = CGRect(x: 50, y: 0, width: 200, height: 150)
        let bottomRect = CGRect(x: 50, y: 150, width: 200, height: 150)
        let shoesRect = CGRect(x: 50, y: 300, width: 200, height: 100)
        
        top.draw(in: topRect)
        bottom.draw(in: bottomRect)
        shoes.draw(in: shoesRect)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
}
