//
//  NewToDoPresenter.swift
//  ToDoList
//
//  Created by SIARHEI LUKYANAU on 27.08.2024.
//

import Foundation

protocol NewToDoPresenterProtocol: AnyObject {
    func dismissNewTodo()
}

class NewToDoPresenter: NewToDoPresenterProtocol {
    
    weak var view: NewToDoViewProtocol!
    var interactor: NewToDoInteractorProtocol!
    var router: NewToDoRouterProtocol!
    
    required init(view: NewToDoViewProtocol) {
        self.view = view
    }
    
    func dismissNewTodo() {
        router.dismissNewTodo()
    }
}
