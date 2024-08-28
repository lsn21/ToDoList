//
//  MainInteractor.swift
//  ToDoList
//
//  Created by SIARHEI LUKYANAU on 26.08.2024.
//

import Foundation
import UIKit

protocol MainInteractorProtocol: AnyObject {
    func fetchData()
    func switchChanged(_ sender: UISwitch)
    func removeRecord(_ indexPath: IndexPath)
    func saveTodo(_ newToDo: ToDoRecord?, isNew: Bool)
}

class MainInteractor: MainInteractorProtocol {
    
    weak var presenter: MainPresenterProtocol!
    
    var toDoRecords: [ToDoRecord]?
    
    required init(presenter: MainPresenterProtocol) {
        self.presenter = presenter
    }
    
    func fetchData() {
        // Загружаем данные при загрузке контроллера
        toDoRecords = StorageService.shared.loadTodos()
        
        // Если БД пуста, получаем данные с сервера
        if toDoRecords?.isEmpty == true {
            getToDoList()
        }
        else {
            presenter.didFetchData(data: toDoRecords ?? [ToDoRecord]())
        }
    }
    
    func switchChanged(_ sender: UISwitch) {
        let id = sender.tag
        let index = getIndexById(id)

        toDoRecords?[index].completed = sender.isOn
        DispatchQueue.global(qos: .background).async {
            StorageService.shared.updateTodo(self.toDoRecords?[index] ?? ToDoRecord())
        }
    }
    
    func removeRecord(_ indexPath: IndexPath) {
        let index = indexPath.row
        let id = toDoRecords?[index].id ?? 0
        
        // Удалить из БД
        DispatchQueue.global(qos: .background).async {
            StorageService.shared.deleteTodo(id)
            
            // Удалить элемент из массива
            DispatchQueue.main.async { [weak self] in
                self?.toDoRecords?.remove(at: index)
                self?.presenter.didFetchData(data: self?.toDoRecords ?? [ToDoRecord]())
            }
        }
    }
    
    func saveTodo(_ toDo: ToDoRecord?, isNew: Bool) {
        let newId = StorageService.shared.getNextId()
        let id = isNew ? newId : toDo?.id
        let todo = toDo?.todo
        let description = toDo?.description
        let date = toDo?.date
        let completed = toDo?.completed

        let record = ToDoRecord(id: id, todo: todo, description: description, date: date, completed: completed)
        
        if isNew {
            toDoRecords?.append(record)
        }
        else {
            let count = toDoRecords?.count ?? 0
            for i in 0..<count {
                if toDoRecords?[i].id == record.id {
                    toDoRecords?[i] = record
                    break
                }
            }
        }

        DispatchQueue.global(qos: .background).async {

            if isNew {
                StorageService.shared.addTodo(record)
            }
            else {
                StorageService.shared.updateTodo(record)
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.presenter.didFetchData(data: self?.toDoRecords ?? [ToDoRecord]())
            }
        }
    }

    
    private func getToDoList() {
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            let url = "https://dummyjson.com/todos"
            ServerService.shared.fetchToDoData(from: url) { answer in
                guard let self = self else { return }
                
                if let answer = answer, let todos = answer.todos {
                    self.toDoRecords = todos
                    for i in 0..<todos.count {
                        if todos[i].date == nil {
                            self.toDoRecords?[i].date = Date()
                        }
                    }
                    StorageService.shared.saveTodos(self.toDoRecords)
                    DispatchQueue.main.async { [weak self] in
                        self?.presenter.didFetchData(data: self?.toDoRecords ?? [ToDoRecord]())
                    }
                } else {
                    print("Failed to fetch person data.")
                }
            }
        }
    }
    
    private func getIndexById(_ id: Int) -> Int {
        return toDoRecords?.firstIndex(where: { $0.id == id }) ?? 0
    }
}
