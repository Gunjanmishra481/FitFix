import UIKit
import FirebaseCore
 // Add this import

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    // Override point for customization after application launch.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create a window for the app
        window = UIWindow(frame: UIScreen.main.bounds)

        // Create an instance of the OutfitEditableViewController
        let outfitEditableVC = OutfitEditableViewController()

        // Embed the OutfitEditableViewController in a UINavigationController
        let navigationController = UINavigationController(rootViewController: outfitEditableVC)

        // Set the root view controller of the window to the navigation controller
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure Google Sign-In with GIDConfiguration
        if let clientID = FirebaseApp.app()?.options.clientID {
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
        }

        return true
    }

    // Handle URL redirects for Google Sign-In
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // Other AppDelegate methods...
}
