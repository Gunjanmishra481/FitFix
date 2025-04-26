import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import AuthenticationServices  // Import Apple authentication framework

class SignUpViewController: UIViewController, UITextFieldDelegate {

    // Outlets
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var emailPhoneField: UITextField!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signUpApple: UIButton!
    @IBOutlet weak var signUpGoogle: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGradientBackground()
        setupKeyboardDismissal()
        fullNameField.frame.size.height = 50
        passwordField.frame.size.height = 50
        emailPhoneField.frame.size.height = 50
    }
    
    class User {
        static let shared = User()
        var email: String?
        var name: String?
        
        func saveToFirebase() {
            guard let uid = Auth.auth().currentUser?.uid else {
                print("No current user UID available.")
                return
            }
            let db = Firestore.firestore()
            db.collection("users").document(uid).setData([
                "name": name ?? "",
                "email": email ?? ""
            ]) { error in
                if let error = error {
                    print("Error saving user data: \(error)")
                } else {
                    print("User data saved successfully")
                }
            }
        }
    }
    
    private func setupKeyboardDismissal() {
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUI() {
        // Setup corner radius for text fields and buttons
        fullNameField.layer.cornerRadius = 12
        emailPhoneField.layer.cornerRadius = 12
        passwordField.layer.cornerRadius = 12
        signUpButton.layer.cornerRadius = 12
        signUpApple.layer.cornerRadius = 12
        signUpGoogle.layer.cornerRadius = 12
        
        fullNameField.clipsToBounds = true
        emailPhoneField.clipsToBounds = true
        passwordField.clipsToBounds = true
        signUpButton.clipsToBounds = true
        signUpApple.clipsToBounds = true
        signUpGoogle.clipsToBounds = true
        
        fullNameField.delegate = self
        emailPhoneField.delegate = self
        passwordField.delegate = self
        
        // Padding for text fields
        let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        fullNameField.layoutMargins = padding
        emailPhoneField.layoutMargins = padding
        passwordField.layoutMargins = padding
        
        // Initial border setup
        fullNameField.layer.borderWidth = 0
        emailPhoneField.layer.borderWidth = 0
        passwordField.layer.borderWidth = 0
        
        fullNameField.backgroundColor = .white
        emailPhoneField.backgroundColor = .white
        passwordField.backgroundColor = .white
    }
    
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.95, green: 0.92, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.78, green: 0.72, blue: 1.0, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = backgroundView.bounds
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // UITextFieldDelegate methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor(red: 0.333, green: 0.275, blue: 0.392, alpha: 1.0).cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
        textField.layer.borderColor = nil
    }
    
    // MARK: - Email/Password Sign Up
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        guard let fullName = fullNameField.text, !fullName.isEmpty,
              let email = emailPhoneField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert("Please fill in all fields.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.showAlert("Sign up failed: \(error.localizedDescription)")
                return
            }
            
            User.shared.email = email
            User.shared.name = fullName
            User.shared.saveToFirebase()
            self?.navigateToHomePage()
        }
    }
    
    // MARK: - Google Sign In
    @IBAction func signUpGoogleTapped(_ sender: UIButton) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert("Google Sign-In failed: \(error.localizedDescription)")
                return
            }
            
            guard let signInResult = signInResult else { return }
            let user = signInResult.user
            let idToken = user.idToken?.tokenString
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken!, accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.showAlert("Firebase authentication failed: \(error.localizedDescription)")
                    return
                }
                
                if let user = authResult?.user {
                    User.shared.email = user.email
                    User.shared.name = user.displayName
                    if authResult?.additionalUserInfo?.isNewUser ?? false {
                        User.shared.saveToFirebase()
                    }
                    self.navigateToHomePage()
                }
            }
        }
    }
    
    // MARK: - Apple Sign In for Sign Up
    @IBAction func signUpAppleTapped(_ sender: UIButton) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        // Requesting full name and email for first time sign ups
        request.requestedScopes = [.fullName, .email]
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }
    
    func navigateToHomePage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "TabBarHome") as? UITabBarController {
            homeVC.modalPresentationStyle = .fullScreen
            self.present(homeVC, animated: true, completion: nil)
        }
    }
    
    // Show alert message
    func showAlert(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // Action for navigating to the Sign In page
    @IBAction func siginTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        }
    }
}

// MARK: - Apple Sign In Delegates for SignUpViewController
extension SignUpViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // Provide the presentation anchor for the Apple sign in sheet
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    // Successful authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityTokenData = appleIDCredential.identityToken,
           let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: identityTokenString,
                                                      rawNonce: "")
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if let error = error {
                    self?.showAlert("Apple Sign-In failed: \(error.localizedDescription)")
                    return
                }
                // Optionally capture the user's name and email if provided (only available on first sign in)
                if let fullName = appleIDCredential.fullName, User.shared.name == nil {
                    let formatter = PersonNameComponentsFormatter()
                    User.shared.name = formatter.string(from: fullName)
                }
                if let email = appleIDCredential.email, User.shared.email == nil {
                    User.shared.email = email
                }
                // Save user data for new users
                if authResult?.additionalUserInfo?.isNewUser ?? false {
                    User.shared.saveToFirebase()
                }
                self?.navigateToHomePage()
            }
        } else {
            self.showAlert("Unable to fetch identity token from Apple.")
        }
    }
    
    // Handle authorization errors
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        showAlert("Apple Sign-In error: \(error.localizedDescription)")
    }
}
