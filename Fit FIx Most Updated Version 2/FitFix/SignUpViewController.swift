//
//  SignUpViewController.swift
//  FitFix
//
//  Created by user@81 on 12/11/24.
//

import UIKit

class SignUpViewController: UIViewController {
    // Declare text fields as properties to access them later
    
    @IBOutlet weak var fullNameField: UITextField!
    
    @IBOutlet weak var emailPhoneField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
    }
    
    
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        // Get the input from text fields
        guard let fullName = fullNameField.text, !fullName.isEmpty,
              let emailPhone = emailPhoneField.text, !emailPhone.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            // Show an error message if any field is empty
            showAlert("Please fill in all fields.")
            return
        }
        
        // Proceed with registration (in this case, show an alert and navigate to login)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
            homeVC.modalPresentationStyle = .fullScreen
            self.present(homeVC, animated: true, completion: nil)
        }
        
    }
    
    func showAlert(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func siginTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            homeVC.modalPresentationStyle = .fullScreen
            self.present(homeVC, animated: true, completion: nil)
            
            
        }
        // Show an alert with a completion handler
    }
}
