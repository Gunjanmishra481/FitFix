//
//  SignUpViewController.swift
//  FitFix
//
//  Created by Gunjan Mishra on 05/11/24.
//

import UIKit

class SignUpViewController: UIViewController {
    
    // Declare text fields as properties to access them later
    let fullNameField = UITextField()
    let emailPhoneField = UITextField()
    let passwordField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    func setupUI() {
        // Setup UI components like labels, text fields, and the sign-up button

        // Sign Up Button
        let signUpButton = UIButton(type: .system)
        signUpButton.setTitle("SIGN UP", for: .normal)
        signUpButton.backgroundColor = .black
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.layer.cornerRadius = 5
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signUpButton)

        // Add target to the sign-up button
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)

        // Set up layout constraints (your existing layout code for all components)
    }
    
    @objc func signUpButtonTapped() {
        // Capture user input from text fields
        guard let fullName = fullNameField.text, !fullName.isEmpty,
              let email = emailPhoneField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            // Handle empty fields (e.g., show an alert)
            showAlert("Please fill in all fields.")
            return
        }
        
        // Create a new user and add to the data model
        let newUser = User2(name: fullName, email: email, password: password)
        users2.append(newUser) // Update the static data model
        
        // Perform segue to the Profile screen after successful sign-up
        performSegue(withIdentifier: "showProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfile" {
            if let profileVC = segue.destination as? ProfileViewController {
                // Pass the newly added user's details to ProfileViewController
                profileVC.name = fullNameField.text
                
            }
        }
    }

    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


