//
//  NewToDoInteractor.swift
//  ToDoList
//
//  Created by SIARHEI LUKYANAU on 27.08.2024.
//

import Foundation

protocol NewToDoInteractorProtocol: AnyObject {
}

class NewToDoInteractor: NewToDoInteractorProtocol {
    
    weak var presenter: NewToDoPresenterProtocol!
    
    required init(presenter: NewToDoPresenterProtocol) {
        self.presenter = presenter
    }

}
