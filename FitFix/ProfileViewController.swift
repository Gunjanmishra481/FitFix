//
//  ProfileViewController.swift
//  FitFix
//
//  Created by Gunjan Mishra on 02/11/24.
//


import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView! // Connect this to your UIImageView in storyboard
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    
    var name: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display static data
        nameLabel.text = name
        dobLabel.text = "25/09/2004"
        genderLabel.text = "Male"
        
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


