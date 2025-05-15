//
//  EventCollectionViewCell.swift
//  FitFix
//
//  Created by user@79 on 18/03/25.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
            super.awakeFromNib()
            let blurEffect = UIBlurEffect(style: .light)
            let blurView = UIVisualEffectView(effect: blurEffect)

        // Set the blur view's frame to match contentView
            blurView.frame = contentView.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Add the blur view to contentView
            contentView.addSubview(blurView)

            contentView.layer.cornerRadius = 14
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor(hex: "A293CA").cgColor
            contentView.layer.shadowColor = UIColor.black.cgColor
            contentView.layer.shadowOpacity = 0.5
            contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
            contentView.layer.shadowRadius = 4
            titleLabel.font = UIFont(name: "System", size: 24)
            titleLabel.textColor = .darkGray
            dateLabel.font = UIFont(name: "System", size: 18)
            dateLabel.textColor = .gray
            
            let stackView = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
            stackView.axis = .horizontal
            stackView.spacing = 16
            stackView.alignment = .center
            stackView.distribution = .equalSpacing
            stackView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
            ])
        }
    
    func configure(with event: Event) {
        titleLabel.text = event.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateLabel.text = dateFormatter.string(from: event.date)
    }
}
