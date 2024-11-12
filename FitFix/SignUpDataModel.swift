//
//  SignUpDataModel.swift
//  FitFix
//
//  Created by Gunjan Mishra on 05/11/24.
//
import Foundation

struct User2 {
    let name: String
    let email: String
    let password: String
}

// Changing to a variable array to allow updates
var users2: [User2] = [
    User2(name: "Gunjan Mishra", email: "gunjanmishra1415@gmail.com", password: "Manash@123"),
    User2(name: "Aviral Saxena", email: "aviralsaxena@gmail.com", password: "aviralsaxena@123"),
    User2(name: "Alqueem Raza", email: "alqueemraza@gmail.com", password: "alqueemraza@123")
]

