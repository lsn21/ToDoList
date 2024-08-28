//
//  ToDoPresenter.swift
//  ToDoList
//
//  Created by SIARHEI LUKYANAU on 27.08.2024.
//

import Foundation

protocol ToDoPresenterProtocol: AnyObject {
    func dismissNewTodo()
}

class ToDoPresenter: ToDoPresenterProtocol {
    
    weak var view: ToDoViewProtocol!
    var interactor: ToDoInteractorProtocol!
    var router: ToDoRouterProtocol!
    
    required init(view: ToDoViewProtocol) {
        self.view = view
    }
    
    func dismissNewTodo() {
        router.dismissNewTodo()
    }
}
