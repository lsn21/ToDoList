//
//  MainPresenter.swift
//  ToDoList
//
//  Created by SIARHEI LUKYANAU on 26.08.2024.
//

import Foundation
import UIKit

protocol MainPresenterProtocol: AnyObject {
    func configureView()
    func didFetchData(data: [ToDoRecord])
    func switchChanged(_ sender: UISwitch)
    func removeRecord(_ indexPath: IndexPath)
    func openNewTodo()
    func saveNewTodo(_ newToDo: NewToDoEntity?)
}

class MainPresenter: MainPresenterProtocol {
    
    weak var view: MainViewProtocol!
    var interactor: MainInteractorProtocol!
    var router: MainRouterProtocol!
    
    required init(view: MainViewProtocol) {
        self.view = view
    }
    
    func configureView() {
        interactor.fetchData()
    }
    
    func didFetchData(data: [ToDoRecord]) {
        view.displayData(data: data)
    }
    
    func switchChanged(_ sender: UISwitch) {
        interactor.switchChanged(sender)
    }
    
    func removeRecord(_ indexPath: IndexPath) {
        interactor.removeRecord(indexPath)
    }
    
    func openNewTodo() {
        router.showNewToDoScene()
    }
    
    func saveNewTodo(_ newToDo: NewToDoEntity?) {
        interactor.saveNewTodo(newToDo)
    }
}
