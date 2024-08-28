//
//  NewToDoRouter.swift
//  ToDoList
//
//  Created by SIARHEI LUKYANAU on 27.08.2024.
//

import Foundation

protocol NewToDoRouterProtocol: AnyObject {
    func dismissNewTodo()
}

class NewToDoRouter: NewToDoRouterProtocol {
    
    weak var viewController: NewToDoViewController!
    
    init(viewController: NewToDoViewController) {
        self.viewController = viewController
    }
    
    func dismissNewTodo() {
        
        viewController.dismiss(animated: true, completion: nil)
    }
}
