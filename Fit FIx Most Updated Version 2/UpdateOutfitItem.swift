//
//  UpdateOutfitItem.swift
//  FitFix
//
//  Created by md zeyaul mujtaba rizvi on 09/11/24.
//

import UIKit

class UpdateOutfitItem {
    var headImage: UIImage?
    var topImage: UIImage?
    var bottomImage: UIImage?
    var shoesImage: UIImage?
    
    init(headImage: UIImage? = nil, topImage: UIImage? = nil, bottomImage: UIImage? = nil, shoesImage: UIImage? = nil) {
        self.headImage = headImage
        self.topImage = topImage
        self.bottomImage = bottomImage
        self.shoesImage = shoesImage
    }
}

