//
//  ClothingCellCollectionViewCell.swift
//  FitFix
//
//  Created by Gunjan Mishra on 12/11/24.
//

import UIKit

class ClothingCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(with item: ClothingItem) {
        imageView.image = UIImage(named: item.imageName)
    }
}

