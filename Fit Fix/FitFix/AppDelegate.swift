import UIKit

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

        return true
    }

    // Other AppDelegate methods...
}
