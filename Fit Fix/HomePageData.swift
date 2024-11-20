import Foundation

struct OutfitItem {
    let imageName: String
}

class OutfitData {
    static let shared = OutfitData()
    
    // Static data for multiple outfit images
    let outfitItems: [OutfitItem] = [
        OutfitItem(imageName: "HomePageImage"),
        OutfitItem(imageName: "HomePageImage2"),
        OutfitItem(imageName: "HomePageImage3") // Add more images as needed
    ]
}
