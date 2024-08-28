//
//  ToDoRouter.swift
//  ToDoList
//
//  Created by SIARHEI LUKYANAU on 27.08.2024.
//

import Foundation

protocol ToDoRouterProtocol: AnyObject {
    func dismissNewTodo()
}

class ToDoRouter: ToDoRouterProtocol {
    
    weak var viewController: ToDoViewController!
    
    init(viewController: ToDoViewController) {
        self.viewController = viewController
    }
    
    func dismissNewTodo() {
        
        viewController.dismiss(animated: true, completion: nil)
    }
}
