//
//  ClothingCellCollectionViewCell.swift
//  FitFix
//
//  Created by Gunjan Mishra on 12/11/24.
//

//import UIKit
//
//class ClothingCell: UICollectionViewCell {
//    @IBOutlet weak var imageView: UIImageView!
//    
//    func configure(with item: ClothingItem) {
//        // Set the image directly from the item
//        imageView.image = item.imageName
//    }
//}
import UIKit

class ClothingCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    // Selection indicator
    private var selectionOverlay: UIView?
    private var checkmarkImageView: UIImageView?
    
    func configure(with item: ClothingItem) {
        // Use URL to fetch the image
        if let url = URL(string: item.imageName) {
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self?.imageView.image = UIImage(data: data)
                    }
                } else {
                    // Handle errors, set a placeholder image if needed
                    DispatchQueue.main.async {
                        self?.imageView.image = UIImage(systemName: "photo") // Default image or any placeholder
                    }
                }
            }
        } else {
            // If URL creation fails, set a placeholder
            self.imageView.image = UIImage(systemName: "photo")
        }
    }
    
    func showSelectionIndicator(isSelected: Bool) {
        // Create the overlay if it doesn't exist
        if selectionOverlay == nil {
            selectionOverlay = UIView(frame: contentView.bounds)
            selectionOverlay?.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
            selectionOverlay?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            checkmarkImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
            checkmarkImageView?.tintColor = .white
            checkmarkImageView?.translatesAutoresizingMaskIntoConstraints = false
            
            if let checkmarkImageView = checkmarkImageView, let selectionOverlay = selectionOverlay {
                selectionOverlay.addSubview(checkmarkImageView)
                
                NSLayoutConstraint.activate([
                    checkmarkImageView.topAnchor.constraint(equalTo: selectionOverlay.topAnchor, constant: 10),
                    checkmarkImageView.trailingAnchor.constraint(equalTo: selectionOverlay.trailingAnchor, constant: -10),
                    checkmarkImageView.widthAnchor.constraint(equalToConstant: 30),
                    checkmarkImageView.heightAnchor.constraint(equalToConstant: 30)
                ])
            }
        }
        
        // Show or hide the overlay based on selection state
        if isSelected {
            if selectionOverlay?.superview == nil {
                contentView.addSubview(selectionOverlay!)
                contentView.bringSubviewToFront(selectionOverlay!)
            }
        } else {
            selectionOverlay?.removeFromSuperview()
        }
    }
    
    func hideSelectionIndicator() {
        selectionOverlay?.removeFromSuperview()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        hideSelectionIndicator()
    }
}
