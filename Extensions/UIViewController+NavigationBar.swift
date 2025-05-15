//
//  UIViewController+NavigationBar.swift
//  FitFix
//
//  Created by Gunjan Mishra on 16/11/24.
//

import UIKit

extension UIViewController {
    func setupNavigationBar(title: String, leftIcon: String?, rightIcons: [String]) {
        // Set the navigation bar title
        self.navigationItem.title = title
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // Configure left button
        if let leftIcon = leftIcon {
            let leftButton = UIBarButtonItem(
                image: UIImage(systemName: leftIcon),
                style: .plain,
                target: self,
                action: #selector(leftButtonTapped)
            )
            self.navigationItem.leftBarButtonItem = leftButton
        }
        
        // Configure right buttons
        var rightBarButtonItems: [UIBarButtonItem] = []
        for icon in rightIcons {
            let button = UIBarButtonItem(
                image: UIImage(systemName: icon),
                style: .plain,
                target: self,
                action: icon == "calendar" ? #selector(calendarButtonTapped) : #selector(profileButtonTapped)
            )
            rightBarButtonItems.append(button)
        }
        self.navigationItem.rightBarButtonItems = rightBarButtonItems
    }

    // Add actions for button taps
    @objc func leftButtonTapped() {
        print("Left button tapped")
        self.navigationController?.popViewController(animated: true) // Example: Go back
    }
    
    @objc func calendarButtonTapped() {
        print("Calendar button tapped")
        // Navigate to calendar page or perform an action
    }
    
    @objc func profileButtonTapped() {
        print("Profile button tapped")
        // Navigate to profile page or perform an action
    }
}
