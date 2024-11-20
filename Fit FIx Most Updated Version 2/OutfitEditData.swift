import UIKit

struct OutfitItem2 {
    var name: String
    var image: UIImage

    // Initializer to convert ClothingItem to OutfitItem2
    init(from clothingItem: ClothingItem) {
        self.name = clothingItem.category // Use the category as the name
        self.image = clothingItem.imageName // Directly assign the UIImage
    }
}
