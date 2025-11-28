//
//  ToDoPresenter.swift
//  ToDoList
//
//  Created by Siarhei Lukyanau on 17.08.25.
//  telegram: @LSN777, email: LSN21@YA.RU
//

import Foundation

protocol ToDoPresenterProtocol: AnyObject {
    func dismissNewTodo()
}

class ToDoPresenter: ToDoPresenterProtocol {
    
    weak var view: ToDoViewProtocol?
    var interactor: ToDoInteractorProtocol?
    var router: ToDoRouterProtocol?
    
    required init(view: ToDoViewProtocol) {
        self.view = view
    }
    
    func dismissNewTodo() {
        router?.dismissNewTodo()
    }
}
