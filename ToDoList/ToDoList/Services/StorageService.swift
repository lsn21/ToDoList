//
//  StorageService.swift
//  ToDoList
//
//  Created by Siarhei Lukyanau on 17.08.25.
//  telegram: @LSN777, email: LSN21@YA.RU
//

import UIKit
import CoreData

protocol StorageServiceProtocol: AnyObject {
    func loadTodos() async -> [ToDoRecord]?
    func saveTodos(_ toDoRecords: [ToDoRecord]?) async
    func addTodo(_ todo: ToDoRecord) async
    func updateTodo(_ todo: ToDoRecord) async
    func deleteTodo(_ id: Int) async
    func getNextId() async -> Int
}

@MainActor
class ContextManager {
    static let shared = ContextManager()
    private var _context: NSManagedObjectContext?
    
    func setContext(_ context: NSManagedObjectContext) {
        self._context = context
    }
    
    func getContext() -> NSManagedObjectContext {
        // Если _context уже инициализирован, возвращаем его
        if let context = _context {
            return context
        }
        // Если _context не инициализирован, получаем его из AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Не удалось получить AppDelegate.")
        }
        return appDelegate.persistentContainer.viewContext
    }
}

actor StorageService: StorageServiceProtocol {
    
    static let shared = StorageService()
    
    private func getContext() async -> NSManagedObjectContext {
        return await ContextManager.shared.getContext()
    }
    
    // Загружаем данные из БД
    func loadTodos() async -> [ToDoRecord]? {
        let request: NSFetchRequest<ToDoEntity> = ToDoEntity.fetchRequest()
        var toDoRecords = [ToDoRecord]()

        do {
            let context = await getContext()
            let toDoEntities = try context.fetch(request)
            toDoEntities.forEach { toDoEntity in
                var toDoRecord = ToDoRecord()
                toDoRecord.id = Int(toDoEntity.id)
                toDoRecord.todo = toDoEntity.todo
                toDoRecord.description = toDoEntity.descript
                toDoRecord.date = toDoEntity.date
                toDoRecord.completed = toDoEntity.completed
                toDoRecords.append(toDoRecord)
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
        return toDoRecords
    }
    
    // Сохраняем данные полученные с сервера в БД
    func saveTodos(_ toDoRecords: [ToDoRecord]?) async {
        let context = await getContext()
        for todo in (toDoRecords ?? []) {
            let todoEntity = ToDoEntity(context: context)
            if let id = todo.id {
                todoEntity.id = Int16(id)
                todoEntity.todo = todo.todo ?? ""
                todoEntity.descript = todo.description ?? ""
                todoEntity.completed = todo.completed ?? false
                todoEntity.date = todo.date ?? Date()
            }
        }
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    // Добавляем новую запись в БД
    func addTodo(_ todo: ToDoRecord) async {
        let context = await getContext()
        let todoEntity = ToDoEntity(context: context)
        if let id = todo.id {
            todoEntity.id = Int16(id)
            todoEntity.todo = todo.todo ?? ""
            todoEntity.descript = todo.description ?? ""
            todoEntity.completed = todo.completed ?? false
            todoEntity.date = todo.date ?? Date()
            do {
                try context.save()
            } catch {
                print("Error saving context \(error)")
            }
        }
    }
    
    // Обновляем существующую запись в БД
    func updateTodo(_ todo: ToDoRecord) async {
        if let id = todo.id {
            let fetchRequest: NSFetchRequest<ToDoEntity> = ToDoEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)
            
            do {
                let context = await getContext()
                let existingTodos = try context.fetch(fetchRequest)

                if let todoEntity = existingTodos.first {
                    todoEntity.todo = todo.todo ?? ""
                    todoEntity.descript = todo.description ?? ""
                    todoEntity.completed = todo.completed ?? false
                    todoEntity.date = todo.date ?? Date()

                    try context.save()
                    print("Задача обновлена.")
                }
                else {
                    print("Задача с id \(id) не найдена.")
                }
            } catch {
                print("Ошибка при обновлении задачи: \(error)")
            }
        }
    }
    
    // Удаляем запись в БД по id
    func deleteTodo(_ id: Int) async {
        let fetchRequest: NSFetchRequest<ToDoEntity> = ToDoEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)

        do {
            let context = await getContext()
            let existingTodos = try context.fetch(fetchRequest)
            
            if let todoToDelete = existingTodos.first {
                context.delete(todoToDelete)
                
                if context.hasChanges {
                    do {
                        try context.save()
                        print("Изменения сохранены. Задача с id \(id) удалена.")
                    } catch {
                        print("Ошибка при сохранении изменений: \(error.localizedDescription)")
                    }
                }
            }
            else {
                print("Задача с id \(id) не найдена.")
            }
        } catch {
            print("Ошибка при удалении задачи: \(error)")
        }
    }
    
    // Асинхронный метод для нахождения id для новой записи
    func getNextId() async -> Int {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ToDoEntity.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = ["id"]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchLimit = 1

        do {
            let context = await getContext()
            let results = try context.fetch(fetchRequest)
            if let lastId = results.first as? [String: Any], let id = lastId["id"] as? Int16 {
                return Int(id) + 1
            }
        } catch {
            print("Ошибка при получении максимального id: \(error)")
        }
        return 1 // Если записи нет, начинаем с 1
    }
}
