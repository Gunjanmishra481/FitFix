
import UIKit

class CustomTabBarController: UITabBarController {

    override func viewDidLoad() {
           super.viewDidLoad()
           setupTabBarAppearance()

       }
       
       private func setupTabBarAppearance() {
           if #available(iOS 13.0, *) {
               // Create a new appearance instance
               let appearance = UITabBarAppearance()
               // Configure the appearance as desired.
               // .configureWithDefaultBackground() gives you the default styling with translucency.
               appearance.configureWithDefaultBackground()
               // Optionally, you can add a blur effect to the background.
               appearance.backgroundEffect = UIBlurEffect(style: .light)
               // Set the appearance to the tab bar
               tabBar.standardAppearance = appearance
               // Apply this to each tab bar item
               // For iOS 15 and later, set the scrollEdgeAppearance to match
               if #available(iOS 15.0, *) {
                   tabBar.scrollEdgeAppearance = appearance
               }
           } else {
               // For iOS versions below 13, you can insert a UIVisualEffectView into the tab bar.
               let blurEffect = UIBlurEffect(style: .light)
               let blurView = UIVisualEffectView(effect: blurEffect)
               blurView.frame = tabBar.bounds
               blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
               // Insert the blur view at the back so that it doesn't cover tab bar items.
               tabBar.insertSubview(blurView, at: 0)
           }
       }
   }
