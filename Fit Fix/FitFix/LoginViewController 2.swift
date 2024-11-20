//
//  LoginViewController 2.swift
//  FitFix
//
//  Created by md zeyaul mujtaba rizvi on 03/11/24.
//

import UIKit

class LoginViewController: UIViewController {
    
    // Outlets for email and password text fields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Action for Sign In button
    @IBAction func signInTapped(_ sender: UIButton) {
        // Get the input from text fields
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        // Check credentials
        if isValidCredentials(email: email, password: password) {
            // Credentials are correct, proceed to the next view
            navigateToHomePage()
        } else {
            // Show an error message if credentials are incorrect
            showAlert(message: "Invalid email or password. Please try again.")
        }
    }
    
    // Action for Back button
    @IBAction func navigateToSignUpPage(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpPage") as? SignUpViewController {
            signUpVC.modalPresentationStyle = .fullScreen
            self.present(signUpVC, animated: true, completion: nil)
        }
    }

    
    // Function to validate user credentials
    func isValidCredentials(email: String, password: String) -> Bool {
        for user in users {
            if user.email == email && user.password == password {
                return true
            }
        }
        return false
    }
    
    // Function to navigate to the new view controller
    func navigateToHomePage() {
        // Assuming you have set the identifier for your home page view controller in the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
            homeVC.modalPresentationStyle = .fullScreen
            self.present(homeVC, animated: true, completion: nil)
        }
    }
    
    // Function to show alert message
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
