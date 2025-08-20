//
//  UIViewController+extension.swift
//  ToDoList
//
//  Created by Siarhei Lukyanau on 19.08.25.
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
