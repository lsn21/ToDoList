//
//  MainPresenter.swift
//  ToDoList
//
//  Created by Siarhei Lukyanau on 17.08.25.
//  telegram: @LSN777, email: LSN21@YA.RU
//

import Foundation
import UIKit

protocol MainPresenterProtocol: AnyObject {
    var view: MainViewProtocol? { get set }
    
    func configureView()
    func didFetchData(data: [ToDoRecord])
    func checkButtonTapped(_ sender: UIButton, selected: Bool)
    func removeRecord(_ indexPath: IndexPath)
    func openNewTodo()
    func openEditTodo(_ editToDo: ToDoRecord)
    func saveTodo(_ newToDo: ToDoRecord?, isNew: Bool)
    func search(query: String)
    func didTapActionSheetButton(_ indexPath: IndexPath)
    func didTapShareButton(_ toDoRecord: ToDoRecord)
}

class MainPresenter: MainPresenterProtocol {
    var view: (any MainViewProtocol)?
    
    var interactor: MainInteractorProtocol?
    var router: MainRouterProtocol?
    
    required init(view: MainViewProtocol) {
        self.view = view
    }
    
    func configureView() {
        Task {
            await interactor?.fetchData()
        }
    }
    
    func search(query: String) {
        Task {
            await interactor?.search(query: query)
        }
    }
    
    func didFetchData(data: [ToDoRecord]) {
        view?.displayData(data: data)
    }
    
    func checkButtonTapped(_ sender: UIButton, selected: Bool) {
        Task {
            await interactor?.checkButtonTapped(sender, selected: selected)
        }
    }

    func removeRecord(_ indexPath: IndexPath) {
        Task {
            await interactor?.removeRecord(indexPath)
        }
    }
    
    func openNewTodo() {
        router?.showToDoScene(nil)
    }
    
    func openEditTodo(_ editToDo: ToDoRecord) {
        router?.showToDoScene(editToDo)
    }
    
    func saveTodo(_ newToDo: ToDoRecord?, isNew: Bool) {
        Task {
            await interactor?.saveTodo(newToDo, isNew: isNew)
        }
    }
    
    func didTapActionSheetButton(_ indexPath: IndexPath) {
        view?.showActionSheet(indexPath)
    }
        
    func didTapShareButton(_ toDoRecord: ToDoRecord) {
        let itemsToShare = ["Информация, которой я хочу поделиться.", "Задача: \(toDoRecord.todo ?? "")", "Описание: \(toDoRecord.description ?? "")"]
        view?.showShareActivity(with: itemsToShare)
    }
}

extension MainPresenter: MainInteractorOutputProtocol {
    func didFetchResults(results: [ToDoRecord]) {
        view?.showResults(data: results)
    }
}
