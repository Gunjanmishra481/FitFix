//
//  UserData.swift
//  FitFix
//
//  Created by md zeyaul mujtaba rizvi on 03/11/24.
//

// UserData.swift

import Foundation

struct User {
    let email: String
    let password: String
}

let users: [User] = [
    User(email: "user@example.com", password: "password123"),
    User(email: "admin@example.com", password: "adminpass"),
    User(email: "123", password: "123")
]
