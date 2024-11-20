//
//  CategoryModel.swift
//  category
//
//  Created by user@79 on 06/11/24.
//
import UIKit

struct Category {
    let id: UUID
    var name: String
    var iconName: String
    var Count: Int
}
class DataModel {
    static var categories: [Category] = [
        Category(id: UUID(), name: "Top Wear", iconName: "tshirt", Count: 6),
        Category(id: UUID(), name: "Bottom Wear", iconName: "pants", Count: 4),
        Category(id: UUID(), name: "Foot Wear", iconName: "shoes", Count: 4),
        Category(id: UUID(), name: "Accessories", iconName: "watch", Count: 4)
    ]
}
