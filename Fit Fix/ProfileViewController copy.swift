//
//  ProfileViewController.swift
//  FitFix
//
//  Created by Gunjan Mishra on 02/11/24.
//


import UIKit

class ProfileViewController: UIViewController {
  
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!

    
    var name: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2  // for a circular shape
        profileImageView.clipsToBounds = true

        
        // Display static data
        nameLabel.text = "Gunjan Mishra"

        
        // Make the profile image circular


        makeProfileImageViewCircular()
    }
    
    func makeProfileImageViewCircular() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true // Ensures the image is clipped to the bounds
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // This is to ensure the circular shape is maintained after layout updates
        makeProfileImageViewCircular()
    }
    
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        // Optionally, go back to the sign-up screen
        navigationController?.popToRootViewController(animated: true)
    }
}


