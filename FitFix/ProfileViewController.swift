import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    // Changed from let to var to allow updates
    var tableData: [(String, String)] = [
        ("Name", ""),
        ("Email", ""),
        ("Saved", "")
    ]
    
    var savedOutfits: [ClothingItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGradientBackground()
        setupTableView()
        setupTableViewStyle()
        tableView.delegate = self
        tableView.dataSource = self
    }
    private func setupTableViewStyle() {
        // Create blur effect for table background
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = tableView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundView = blurView
        tableView.backgroundColor = .clear
        
        // Style table view
        tableView.layer.cornerRadius = 20
        tableView.layer.masksToBounds = true
        tableView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tableView.layer.shadowOpacity = 0.4
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .gray
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserData() // Fetch data every time the view appears
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
    func setupUI() {
        // Profile Image View
        profileImageView.image = UIImage(systemName: "person.circle")
        profileImageView.tintColor = .gray
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.layer.cornerRadius = 40
        profileImageView.layer.masksToBounds = true
        
        // Edit Button
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(.systemBlue, for: .normal)
        
        // Sign Out Button
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.setTitleColor(.white, for: .normal)
        signOutButton.backgroundColor = .systemRed
        signOutButton.layer.cornerRadius = 8
        signOutButton.layer.masksToBounds = true
        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
        
        setupCustomBackButton()
    }
    
    private func setupCustomBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(backButtonTapped))
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Fetch User Data from Firestore
    func fetchUserData() {
        guard let user = Auth.auth().currentUser else {
            print("No logged in user found.")
            tableData = [
                ("Name", "Not Logged In"),
                ("Email", "Not Logged In"),
                ("Saved", "")
            ]
            tableView.reloadData()
            return
        }
        
        let userId = user.uid
        let db = Firestore.firestore()
        print("Fetching data for user ID: \(userId)")
        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                self.tableData = [
                    ("Name", "Error"),
                    ("Email", "Error"),
                    ("Saved", "")
                ]
            } else if let document = document, document.exists {
                let data = document.data() ?? [:]
                print("Raw Firestore data: \(data)") // Debug print to see all data
                let name = data["name"] as? String ?? "Unknown"
                let email = data["email"] as? String ?? "Unknown"
                print("Extracted name: \(name)") // Debug print
                print("Extracted email: \(email)") // Debug print
                self.tableData = [
                    ("Name", name),
                    ("Email", email),
                    ("Saved", "")
                ]
            } else {
                print("Document does not exist for user ID: \(userId)")
                // Use data from Firebase Auth user
                let name = user.displayName ?? "Unknown"
                let email = user.email ?? "Unknown"
                self.tableData = [
                    ("Name", name),
                    ("Email", email),
                    ("Saved", "")
                ]
                // Create the document in Firestore with Auth data
                let userData: [String: Any] = [
                    "name": name,
                    "email": email
                ]
                db.collection("users").document(userId).setData(userData) { error in
                    if let error = error {
                        print("Error creating user document: \(error.localizedDescription)")
                    } else {
                        print("User document created successfully.")
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - TableView Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        let data = tableData[indexPath.row]
        cell.textLabel?.text = data.0
        cell.detailTextLabel?.text = data.1
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.detailTextLabel?.textColor = .gray
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        if indexPath.row == 2 {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            let savedVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SavedViewController") as! SavedViewController
            savedVC.savedItems = savedOutfits
            navigationController?.pushViewController(savedVC, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true) // Deselect row after tap
    }
    
    // MARK: - Logout Handling
    func handleLogout() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
            self.logoutAndReturnToLogin()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func logoutAndReturnToLogin() {
        do {
            try Auth.auth().signOut() // Sign out from Firebase
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                loginVC.modalPresentationStyle = .fullScreen
                window.rootViewController = UINavigationController(rootViewController: loginVC)
                window.makeKeyAndVisible()
            }
        }
    }
    
    @objc func signOutTapped() {
        handleLogout()
    }
}
