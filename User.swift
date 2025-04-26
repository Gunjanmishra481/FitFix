//
//  User.swift
//  FitFix
//
//  Created by admin81 on 17/12/24.
//


//
//  User.swift
//  Radiance
//
//  Created by admin12 on 15/12/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class User {
    // Singleton instance
    static let shared = User()
    
    // Properties to store user data
    var email: String?
    var name: String?

    // Private initializer to prevent creating multiple instances
    private init() {
        // Fetch the email from Firebase Auth when the singleton is initialized
        if let currentUserEmail = Auth.auth().currentUser?.email {
            self.email = currentUserEmail
        }
    }

    // Method to save user data to Firebase
    func saveToFirebase() {
        guard let userEmail = email else {
            print("Error: Email is unavailable. User must be logged in.")
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(userEmail)

        let data: [String: Any] = [
            "email": userEmail,              // Save email explicitl      
            "name": name ?? "",
            "createdAt": FieldValue.serverTimestamp()
        ]

        userRef.setData(data, merge: true) { error in
            if let error = error {
                print("Error saving data: \(error.localizedDescription)")
            } else {
                print("User data successfully saved to Firebase.")
            }
        }
    }
}
