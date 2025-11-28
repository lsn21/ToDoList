//
//  MainInteractor.swift
//  ToDoList
//
//  Created by Siarhei Lukyanau on 17.08.25.
//  telegram: @LSN777, email: LSN21@YA.RU
//

import Foundation
import UIKit

protocol MainInteractorProtocol: AnyObject {
    func fetchData() async
    func checkButtonTapped(_ sender: UIButton, selected: Bool) async
    func removeRecord(_ indexPath: IndexPath) async
    func saveTodo(_ newToDo: ToDoRecord?, isNew: Bool) async
    func search(query: String) async
}

protocol MainInteractorOutputProtocol: AnyObject {
    func didFetchResults(results: [ToDoRecord])
}

class MainInteractor: MainInteractorProtocol {
    
    weak var output: MainInteractorOutputProtocol?
    weak var presenter: MainPresenterProtocol?
    
    var toDoRecords: [ToDoRecord]?
    
    required init(presenter: MainPresenterProtocol) {
        self.presenter = presenter
    }
    
    func sortToDoRecords(_ toDoRecords: [ToDoRecord]?) -> [ToDoRecord] {
        let sortedToDoRecords = toDoRecords?.sorted(by:  { toDoRecord1, toDoRecord2 in
            let date1 = toDoRecord1.date ?? Date()
            let date2 = toDoRecord2.date ?? Date()
            return date1 > date2
        }) ?? [ToDoRecord]()
        return sortedToDoRecords
    }
    
    func search(query: String) async {
        await fetchData()
        
        let results = toDoRecords?.filter { record in
            guard let todo = record.todo else { return false }
            guard let description = record.description else { return false }
            let titleAndDescript = "\(todo) \(description)"
            return titleAndDescript.lowercased().contains(query.lowercased())
        } ?? [ToDoRecord]()
        let sortResults = sortToDoRecords(results)
        
        // Обновляем интерфейс на главном потоке
        Task { @MainActor in
            self.output?.didFetchResults(results: sortResults)
        }
    }
    
    func fetchData() async {
        // Загружаем данные при загрузке контроллера
        toDoRecords = await StorageService.shared.loadTodos()
        toDoRecords = sortToDoRecords(toDoRecords)

        // Если БД пуста, получаем данные с сервера
        if toDoRecords?.isEmpty == true {
            getToDoList()
        }
        else {
            Task { @MainActor in
                presenter?.didFetchData(data: toDoRecords ?? [ToDoRecord]())
            }
        }
    }

    func checkButtonTapped(_ sender: UIButton, selected: Bool) async {
        let id = await sender.tag
        let index = getIndexById(id)

        toDoRecords?[index].completed = selected
        Task {
            await StorageService.shared.updateTodo(self.toDoRecords?[index] ?? ToDoRecord())
            Task { @MainActor in
                presenter?.didFetchData(data: self.toDoRecords ?? [ToDoRecord]())
            }
        }
    }

    func removeRecord(_ indexPath: IndexPath) async {
        let index = indexPath.row
        let id = toDoRecords?[index].id ?? 0
        
        // Удалить из БД
        Task {
            await StorageService.shared.deleteTodo(id)
            Task { @MainActor in
                self.toDoRecords?.remove(at: index)
                presenter?.didFetchData(data: self.toDoRecords ?? [ToDoRecord]())
            }
        }
    }
    
    func saveTodo(_ toDo: ToDoRecord?, isNew: Bool) async {
        let newId = await StorageService.shared.getNextId()
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
        toDoRecords = sortToDoRecords(toDoRecords)

        Task {
            if isNew {
                await StorageService.shared.addTodo(record)
            } else {
                await StorageService.shared.updateTodo(record)
            }
            Task { @MainActor in
                self.presenter?.didFetchData(data: self.toDoRecords ?? [ToDoRecord]())
            }
        }
    }

    private func getToDoList() {
        Task { [weak self] in
            let url = "https://dummyjson.com/todos"
            var answer: ToDoAnswer?
            do {
                answer = try await ServerService.shared.fetchToDoData(from: url)
            } catch {
                print("Expected successful fetch, but got error: \(error)")
            }

            guard let self = self else { return }
            
            if let answer = answer, let todos = answer.todos {
                self.toDoRecords = sortToDoRecords(todos)

                // Устанавливаем дату для задач, у которых она отсутствует
                for i in 0..<todos.count {
                    if todos[i].date == nil {
                        self.toDoRecords?[i].date = Date()
                    }
                }
                // Сохраняем данные в StorageService
                await StorageService.shared.saveTodos(self.toDoRecords)
                
                // Обновляем UI на главном потоке
                Task { @MainActor in
                    self.presenter?.didFetchData(data: self.toDoRecords ?? [ToDoRecord]())
                }
            }
            else {
                print("Failed to fetch person data.")
            }
        }
    }
    
    private func getIndexById(_ id: Int) -> Int {
        return toDoRecords?.firstIndex(where: { $0.id == id }) ?? 0
    }
}
