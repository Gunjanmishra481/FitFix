import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import AuthenticationServices  // Import Apple authentication framework

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signInApple: UIButton!
    @IBOutlet weak var signInGoogle: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupKeyboardDismissal()
        setupUI()
    }
    
    // MARK: - Google Sign In
    @IBAction func signInGoogleTapped(_ sender: UIButton) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(message: "Google Sign-In failed: \(error.localizedDescription)")
                return
            }
            
            guard let signInResult = signInResult else { return }
            let user = signInResult.user
            let idToken = user.idToken?.tokenString
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken!, accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.showAlert(message: "Firebase authentication failed: \(error.localizedDescription)")
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
    
    // MARK: - Apple Sign In for Login
    @IBAction func signInAppleTapped(_ sender: UIButton) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        // For sign in, you can request only the minimal scopes
        request.requestedScopes = [.fullName, .email]
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }
    
    // MARK: - Email/Password Sign In
    @IBAction func signInTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter your email and password.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.showAlert(message: "Login failed: \(error.localizedDescription)")
                return
            }
            
            User.shared.email = Auth.auth().currentUser?.email
            self?.fetchUserData {
                self?.navigateToHomePage()
            }
        }
    }
    
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUI() {
        emailTextField.layer.cornerRadius = 12
        passwordTextField.layer.cornerRadius = 12
        signInButton.layer.cornerRadius = 12
        signInApple.layer.cornerRadius = 12
        signInGoogle.layer.cornerRadius = 12
        
        emailTextField.clipsToBounds = true
        passwordTextField.clipsToBounds = true
        signInButton.clipsToBounds = true
        signInGoogle.clipsToBounds = true
        signInApple.clipsToBounds = true
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        emailTextField.layoutMargins = padding
        passwordTextField.layoutMargins = padding
        
        emailTextField.layer.borderWidth = 0
        passwordTextField.layer.borderWidth = 0
        
        emailTextField.backgroundColor = .white
        passwordTextField.backgroundColor = .white
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor(red: 0.333, green: 0.275, blue: 0.392, alpha: 1.0).cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
        textField.layer.borderColor = nil
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
    
    // Fetch user data from Firestore after sign in
    private func fetchUserData(completion: @escaping () -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No current user UID available.")
            completion()
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                User.shared.name = data?["name"] as? String
            } else {
                print("Document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
            }
            completion()
        }
    }
    
    @IBAction func navigateToSignUpPage(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpPage") as? SignUpViewController {
            signUpVC.modalPresentationStyle = .fullScreen
            self.present(signUpVC, animated: true, completion: nil)
        }
    }
    
    func navigateToHomePage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "TabBarHome") as? UITabBarController {
            homeVC.modalPresentationStyle = .fullScreen
            self.present(homeVC, animated: true, completion: nil)
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Apple Sign In Delegates for LoginViewController
extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityTokenData = appleIDCredential.identityToken,
           let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: identityTokenString,
                                                      rawNonce: "")
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if let error = error {
                    self?.showAlert(message: "Apple Sign-In failed: \(error.localizedDescription)")
                    return
                }
                // Optionally update user data using the provided info
                if let fullName = appleIDCredential.fullName, User.shared.name == nil {
                    let formatter = PersonNameComponentsFormatter()
                    User.shared.name = formatter.string(from: fullName)
                }
                if let email = appleIDCredential.email, User.shared.email == nil {
                    User.shared.email = email
                }
                // Save new user info if needed
                if authResult?.additionalUserInfo?.isNewUser ?? false {
                    User.shared.saveToFirebase()
                }
                self?.navigateToHomePage()
            }
        } else {
            self.showAlert(message: "Unable to fetch identity token from Apple.")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        showAlert(message: "Apple Sign-In error: \(error.localizedDescription)")
    }
}
