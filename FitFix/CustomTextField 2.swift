//
//  CustomTextField.swift
//  FitFix
//
//  Created by Gunjan Mishra on 03/11/24.
//

import UIKit

class CustomTextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.backgroundColor = UIColor(red: 249/255, green: 250/255, blue: 250/255, alpha: 1).cgColor
        layer.cornerRadius = 25
        
        
        
    }

}
