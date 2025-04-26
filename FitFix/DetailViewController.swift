//
//  DetailViewController.swift
//  category
//
//  Created by user@79 on 06/11/24.
//

import UIKit

class DetailViewController: UIViewController {
    var category: Category?

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the background color to Thistle

        if let category = category {
            nameLabel.text = category.name
            countLabel.text = "Count: \(category.count)"
        }
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
