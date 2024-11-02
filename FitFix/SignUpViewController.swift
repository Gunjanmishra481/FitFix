//
//  SignUpViewController.swift
//  FitFix
//
//  Created by Gunjan Mishra on 02/11/24.
//


import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pre-fill static data
        fullNameTextField.text = "Gunjan Mishra"
        emailTextField.text = "gunjanmishra1415@gmail.com"
        passwordTextField.text = "password123"
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        // Perform segue to the Profile screen
        performSegue(withIdentifier: "showProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfile" {
            if let profileVC = segue.destination as? ProfileViewController {
                profileVC.name = fullNameTextField.text // Pass the name to ProfileViewController
            }
        }
    }
}

