//
//  EventTableViewCell.swift
//  calendareminder
//
//  Created by user@79 on 09/11/24.
//
import UIKit

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with event: Event) {
        titleLabel.text = event.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateLabel.text = dateFormatter.string(from: event.date)
    }
}
