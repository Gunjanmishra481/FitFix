//
//  CategoryCell.swift
//  category
//
//  Created by user@79 on 06/11/24.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    @IBOutlet weak var count: UILabel!
    
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
            super.awakeFromNib()
            
            // Round the corners of the cell
            self.layer.cornerRadius = 12 // Adjust the radius as needed
            self.layer.masksToBounds = true
            self.layer.shadowColor = UIColor.black.cgColor
                self.layer.shadowOpacity = 0.1  // Adjust shadow opacity
                self.layer.shadowOffset = CGSize(width: 0, height: 0)  // Adjust shadow offset
                self.layer.shadowRadius = 5
        }
}

