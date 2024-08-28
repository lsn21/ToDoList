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
    func openEditTodo(_ editToDo: ToDoRecord)
    func saveTodo(_ newToDo: ToDoRecord?, isNew: Bool)
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
        router.showToDoScene(nil)
    }
    
    func openEditTodo(_ editToDo: ToDoRecord) {
        router.showToDoScene(editToDo)
    }
    
    func saveTodo(_ newToDo: ToDoRecord?, isNew: Bool) {
        interactor.saveTodo(newToDo, isNew: isNew)
    }
}
