//
//  UIViewController.swift
//  KAIMEMO
//
//  Created by 藤崎花音 on 2024/11/29.
//

import Foundation
import UIKit

extension UIViewController {
    func setDismissKeyboard() {
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
