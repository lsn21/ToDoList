//
//  ToDoInteractor.swift
//  ToDoList
//
//  Created by SIARHEI LUKYANAU on 27.08.2024.
//

import Foundation

protocol ToDoInteractorProtocol: AnyObject {
}

class ToDoInteractor: ToDoInteractorProtocol {
    
    weak var presenter: ToDoPresenterProtocol!
    
    required init(presenter: ToDoPresenterProtocol) {
        self.presenter = presenter
    }

}
