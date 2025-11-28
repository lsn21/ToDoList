//
//  UIViewController+extension.swift
//  ToDoList
//
//  Created by Siarhei Lukyanau on 17.08.25.
//  telegram: @LSN777, email: LSN21@YA.RU
//

import UIKit

extension UIViewController {
    
    func dismissKeyboardL153() {
        
        let tapGL153: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboardTouchOutsideL153))
        
        tapGL153.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tapGL153)
    }
    
    @objc private func dismissKeyboardTouchOutsideL153() {
        print("dismissKeyboardTouchOutsideL153")
        
        view.endEditing(true)
    }
}
