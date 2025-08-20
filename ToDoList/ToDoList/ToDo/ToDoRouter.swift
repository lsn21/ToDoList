//
//  ToDoRouter.swift
//  ToDoList
//
//  Created by Siarhei Lukyanau on 17.08.25.
//

import Foundation

protocol ToDoRouterProtocol: AnyObject {
    func dismissNewTodo()
}

class ToDoRouter: ToDoRouterProtocol {
    
    weak var viewController: ToDoViewController?
    
    init(viewController: ToDoViewController) {
        self.viewController = viewController
    }
    
    func dismissNewTodo() {
        
        viewController?.dismiss(animated: true, completion: nil)
    }
}
