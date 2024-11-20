import UIKit


struct ClothingItem {
    let category: String
    let imageName: UIImage
}

struct ClothingData {
    static var items: [ClothingItem] = [
        ClothingItem(category: "Tops", imageName: UIImage(named: "a") ?? UIImage()),
        ClothingItem(category: "Tops", imageName: UIImage(named: "b") ?? UIImage()),
        ClothingItem(category: "Tops", imageName: UIImage(named: "c") ?? UIImage()),
        ClothingItem(category: "Tops", imageName: UIImage(named: "d") ?? UIImage()),
        ClothingItem(category: "Tops", imageName: UIImage(named: "e") ?? UIImage()),
        ClothingItem(category: "Tops", imageName: UIImage(named: "f") ?? UIImage())
    ]
}

struct BottomsData {
    static var items: [ClothingItem] = [
        ClothingItem(category: "Bottoms", imageName: UIImage(named: "g") ?? UIImage()),
        ClothingItem(category: "Bottoms", imageName: UIImage(named: "h") ?? UIImage()),
        ClothingItem(category: "Bottoms", imageName: UIImage(named: "i") ?? UIImage()),
        ClothingItem(category: "Bottoms", imageName: UIImage(named: "j") ?? UIImage())
    ]
}

struct ShoesData {
    static var items: [ClothingItem] = [
        ClothingItem(category: "Shoes", imageName: UIImage(named: "k") ?? UIImage()),
        ClothingItem(category: "Shoes", imageName: UIImage(named: "l") ?? UIImage()),
        ClothingItem(category: "Shoes", imageName: UIImage(named: "m") ?? UIImage()),
        ClothingItem(category: "Shoes", imageName: UIImage(named: "n") ?? UIImage())
    ]
}

struct AccessoriesData {
    static var items: [ClothingItem] = [
        ClothingItem(category: "Accessories", imageName: UIImage(named: "o") ?? UIImage()),
        ClothingItem(category: "Accessories", imageName: UIImage(named: "p") ?? UIImage()),
        ClothingItem(category: "Accessories", imageName: UIImage(named: "q") ?? UIImage()),
        ClothingItem(category: "Accessories", imageName: UIImage(named: "r") ?? UIImage())
    ]
}
