//
//  ToDoListTests.swift
//  ToDoListTests
//
//  Created by SIARHEI LUKYANAU on 26.08.2024.
//

import XCTest
import CoreData

@testable import ToDoList

class ServerServiceTests: XCTestCase {
    
    var serverService: ServerServiceProtocol!
    
    override func setUp() {
        super.setUp()
        serverService = ServerService.shared
        
        // Установка URLProtocol для подмены сетевых запросов
        URLProtocol.registerClass(MockURLProtocol.self)
    }

    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        super.tearDown()
    }
    
    // Тест на успешное получение и декодирование данных. Здесь мы задаем ожидаемый ответ и проверяем, что метод завершился успешно с правильными данными.
    func testFetchToDoData_Success() {
        let expectation = self.expectation(description: "Fetch ToDoData success")
        
        // Настройка мок-данных на успех
        let todos = ToDoRecord(id: 1, todo: "Do something nice for someone you care about", completed: false)
        let answer = ToDoAnswer(todos: [todos])
        let mockResponse = answer
        MockURLProtocol.mockResponseData = try? JSONEncoder().encode(mockResponse)
        
        serverService.fetchToDoData(from: "https://dummyjson.com/todos") { result in
            XCTAssertNotNil(result)
            XCTAssertEqual(result, mockResponse)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Тест на входные данные с некорректным URL. Ожидается, что результат будет nil.
    func testFetchToDoData_InvalidURL() {
        let expectation = self.expectation(description: "Fetch ToDoData invalid URL")
        
        serverService.fetchToDoData(from: "invalid-url") { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Тест, который моделирует ситуацию, когда сервер не возвращает данных. Ожидается, что результат будет nil.
    func testFetchToDoData_NoData() {
        let expectation = self.expectation(description: "Fetch ToDoData no data")
        
        // Настройка мок-данных для теста без данных
        MockURLProtocol.mockResponseData = nil
        MockURLProtocol.mockResponseError = nil
        
        serverService.fetchToDoData(from: "https://dummyjson.com/todos") { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // Тест на обработку ошибочного ответа, который невозможно декодировать в `ToDoAnswer`. Ожидается, что результат будет nil.
    func testFetchToDoData_DecodingError() {
        let expectation = self.expectation(description: "Fetch ToDoData decoding error")
        
        // Настройка мок-данных для теста с ошибкой декодирования
        MockURLProtocol.mockResponseData = "invalid json".data(using: .utf8)
        
        serverService.fetchToDoData(from: "") { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}

// Мок URLProtocol для перехвата запросов
class MockURLProtocol: URLProtocol {
    
    static var mockResponseData: Data?
    static var mockResponseError: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true // Перехватываем все запросы
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = MockURLProtocol.mockResponseError {
            client?.urlProtocol(self, didFailWithError: error)
        } else if let data = MockURLProtocol.mockResponseData {
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)
            client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}
 
class MockPersistentContainer {
    let persistentContainer: NSPersistentContainer

    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType  // Используем in-memory хранилище для тестирования
        persistentContainer.persistentStoreDescriptions = [description]

        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
        }
    }
}

class StorageServiceTests: XCTestCase {
    
    var storageService: StorageService!
    var persistentContainer: MockPersistentContainer!
    
    override func setUp() {
        super.setUp()
        
        // Создаем мок-контейнер
        persistentContainer = MockPersistentContainer(modelName: "ToDoList")
        storageService = StorageService.shared
        storageService.setContext(persistentContainer.persistentContainer.viewContext)
        
        // Очищаем контекст для изоляции тестов
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ToDoEntity.fetchRequest()
        do {
            let items = try persistentContainer.persistentContainer.viewContext.fetch(fetchRequest)
            for item in items {
                if let managedObject = item as? NSManagedObject {
                    persistentContainer.persistentContainer.viewContext.delete(managedObject)
                }
            }
            try persistentContainer.persistentContainer.viewContext.save() // Сохрани контекст
        } catch {
            print("Failed to delete previous data: \(error)")
        }
    }
    
    override func tearDown() {
        // Сброс контекста после теста
        storageService = nil
        persistentContainer.persistentContainer.viewContext.rollback()
        
        storageService = nil
        persistentContainer = nil
        super.tearDown()
    }
    
    func testLoadTodos() {
        let todo = ToDoRecord(id: 1, todo: "Test Todo", description: "Test Description", date: Date(), completed: false)
        storageService.addTodo(todo)
        
        let todos = storageService.loadTodos()
        
        print("Loaded Todos: \(String(describing: todos))") // Добавьте эту строку здесь

        XCTAssertNotNil(todos)
        XCTAssertEqual(todos?.count, 1)
        XCTAssertEqual(todos?.first?.todo, "Test Todo")
        XCTAssertEqual(todos?.first?.description, "Test Description")
    }
    
    func testSaveTodos() {
        let todoRecords = [ToDoRecord(id: 1, todo: "Test Todo 1"), ToDoRecord(id: 2, todo: "Test Todo 1")]
        storageService.saveTodos(todoRecords)
        
        let todos = storageService.loadTodos()
        
        print("Save Todos: \(String(describing: todos))") // Добавьте эту строку здесь

        XCTAssertNotNil(todos)
        XCTAssertEqual(todos?.count, 2)
        XCTAssertEqual(todos?.first?.todo, "Test Todo 1")
    }
    
    func testAddTodo() {
        let todo = ToDoRecord(id: 1, todo: "Test Todo Add", description: "This is a test todo", date: Date(), completed: false)
        storageService.addTodo(todo)

        let todos = storageService.loadTodos()
        
        print("Add Todos: \(String(describing: todos))") // Для отладки

        XCTAssertNotNil(todos)
        XCTAssertEqual(todos?.count, 1)
        XCTAssertEqual(todos?.first?.todo, "Test Todo Add")
        XCTAssertEqual(todos?.first?.description, "This is a test todo")
    }
    
    func testUpdateTodo() {
        let todo = ToDoRecord(id: 4, todo: "Test Todo Update")
        storageService.addTodo(todo) // Сначала добавляем, чтобы потом обновить
        
        let updatedTodo = ToDoRecord(id: 4, todo: "Updated Todo", description: "Updated Description", date: Date(), completed: true)
        storageService.updateTodo(updatedTodo) // Обновляем задачу
        
        let todos = storageService.loadTodos()
        
        print("Update Todos: \(String(describing: todos))") // Добавьте эту строку здесь

        XCTAssertNotNil(todos)
        XCTAssertEqual(todos?.count, 1)
        XCTAssertEqual(todos?.first?.todo, "Updated Todo")
        XCTAssertEqual(todos?.first?.description, "Updated Description")
        XCTAssertEqual(todos?.first?.completed, true)
    }
    
    func testDeleteTodo() {
        let todo = ToDoRecord(id: 5, todo: "Test Todo Delete")
        storageService.addTodo(todo)
        
        storageService.deleteTodo(5) // Удаляем задачу

        let todos = storageService.loadTodos()
        
        print("Delete Todos: \(String(describing: todos))") // Добавьте эту строку здесь

        XCTAssertNotNil(todos)
        XCTAssertEqual(todos?.count, 0) // Проверяем, что задача удалена
    }
    
    func testGetNextId() {
        let nextId = storageService.getNextId()
        XCTAssertEqual(nextId, 1) // Первоначально, у нас еще нет задач, ID должен быть 1
        
        let todo = ToDoRecord(id: 1, todo: "Test Todo 1")
        print("GetNextId Todo: \(String(describing: todo))") // Добавьте эту строку здесь

        storageService.addTodo(todo)
        
        let nextIdAfterAdding = storageService.getNextId()
        XCTAssertEqual(nextIdAfterAdding, 2) // После добавления, следующий ID должен быть 2
    }
}

