//
//  ToDoInteractor.swift
//  ToDoList
//
//  Created by Siarhei Lukyanau on 17.08.25.
//  telegram: @LSN777, email: LSN21@YA.RU
//

import Foundation

protocol ToDoInteractorProtocol: AnyObject {
}

class ToDoInteractor: ToDoInteractorProtocol {
    
    weak var presenter: ToDoPresenterProtocol?
    
    required init(presenter: ToDoPresenterProtocol) {
        self.presenter = presenter
    }

}
