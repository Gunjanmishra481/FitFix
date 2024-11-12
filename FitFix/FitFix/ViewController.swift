//
//  ViewController.swift
//  FitFix
//
//  Created by Gunjan Mishra on 28/10/24.
//

import UIKit

class RegistrationViewController: UIViewController {
    
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
        // Setup your UI components (segmented control, labels, text fields, buttons)

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

        // Add layout constraints (your existing layout code)
    }

    @objc func signUpButtonTapped() {
        // Capture user input from text fields
        guard let fullName = fullNameField.text, !fullName.isEmpty,
              let emailPhone = emailPhoneField.text, !emailPhone.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            // Handle empty fields (e.g., show an alert)
            showAlert("Please fill in all fields.")
            return
        }

        // Perform segue to the Profile screen
        performSegue(withIdentifier: "showProfile", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfile" {
            if let profileVC = segue.destination as? ProfileViewController {
                // Pass data to the ProfileViewController
                profileVC.name = fullNameField.text
                // You can pass email or other data similarly
            }
        }
    }

    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}





