//
//  AddImage.swift
//  FitFix
//
//  Created by user@81 on 19/11/24.
//

import UIKit

class Category2 {
    var name: String
    var count: Int
    var images: [UIImage] // Array to store images for this category

    init(name: String) {
        self.name = name
        self.count = 0
        self.images = []
    }
}

class DataModel2 {
    static var categories: [Category2] = [
        Category2(name: "Top Wear"),
        Category2(name: "Bottom Wear"),
        Category2(name: "Accessories")
        // Add more categories as needed
    ]
}
