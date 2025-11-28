//
//  ToDoListTests.swift
//  ToDoListTests
//
//  Created by Siarhei Lukyanau on 17.08.25.
//  telegram: @LSN777, email: LSN21@YA.RU
//

import XCTest
import CoreData
@testable import ToDoList

class ServerServiceTests: XCTestCase {
    
    var serverService: ServerServiceProtocol?
    
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
    func testFetchToDoData_Success() async throws {
        let expectation = self.expectation(description: "Fetch ToDoData success")
        
        // Настройка мок-данных на успех
        let todos = ToDoRecord(id: 1, todo: "Do something nice for someone you care about", completed: false)
        let answer = ToDoAnswer(todos: [todos])
        let mockResponse = answer
        MockURLProtocol.mockResponseData = try? JSONEncoder().encode(mockResponse)
        
        do {
            let result = try await serverService?.fetchToDoData(from: "https://dummyjson.com/todos")
            XCTAssertNotNil(result)
            XCTAssertEqual(result, mockResponse)
            expectation.fulfill()
        } catch {
            XCTFail("Expected successful fetch, but got error: \(error)")
        }
        await fulfillment(of: [expectation], timeout: 1)
    }

    // Тест на входные данные с некорректным URL. Ожидается, что результат будет nil.
    func testFetchToDoData_InvalidURL() async {
        let expectation = self.expectation(description: "Fetch ToDoData invalid URL")
        
        do {
            let result = try await serverService?.fetchToDoData(from: "invalid-url")
            XCTAssertNil(result)
            expectation.fulfill()
        } catch {
            XCTFail("Expected successful fetch, but got error: \(error)")
        }
        await fulfillment(of: [expectation], timeout: 1)
    }
    
    // Тест, который моделирует ситуацию, когда сервер не возвращает данных. Ожидается, что результат будет nil.
    func testFetchToDoData_NoData() async throws {
        let expectation = self.expectation(description: "Fetch ToDoData no data")
        
        // Настройка мок-данных для теста без данных
        MockURLProtocol.mockResponseData = Data() // Возвращаем пустые данные
        MockURLProtocol.mockResponseError = nil
        
        do {
            let result = try await serverService?.fetchToDoData(from: "https://dummyjson.com/todos")
            XCTAssertNil(result) // Ожидаем, что результат будет nil, так как нет данных для декодирования
            expectation.fulfill()
        } catch {
            XCTFail("Expected successful fetch, but got error: \(error)")
        }
        await fulfillment(of: [expectation], timeout: 1)
    }
    
    // Тест на обработку ошибочного ответа, который невозможно декодировать в `ToDoAnswer`. Ожидается, что результат будет nil.
    func testFetchToDoData_DecodingError() async {
        let expectation = self.expectation(description: "Fetch ToDoData decoding error")
        
        // Настройка мок-данных для теста с ошибкой декодирования
        MockURLProtocol.mockResponseData = "invalid json".data(using: .utf8)
        
        do {
            let result = try await serverService?.fetchToDoData(from: "")
            XCTAssertNil(result)
            expectation.fulfill()
        } catch {
            XCTFail("Expected successful fetch, but got error: \(error)")
        }
        await fulfillment(of: [expectation], timeout: 1)
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
        }
        else if let data = MockURLProtocol.mockResponseData {
            if let url = request.url {
                if let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) {
                    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                    client?.urlProtocol(self, didLoad: data)
                }
            }
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
    
    var сontextManager: ContextManager?
    var storageService: StorageService?
    var persistentContainer: MockPersistentContainer?
    
    override func setUp() {
        super.setUp()
        
        // Создаем мок-контейнер
        persistentContainer = MockPersistentContainer(modelName: "ToDoList")
        storageService = StorageService.shared
        
        Task { @MainActor in
              сontextManager = ContextManager.shared
              if let viewContext = persistentContainer?.persistentContainer.viewContext {
                  сontextManager?.setContext(viewContext)
              }
        }
        
        // Очищаем контекст для изоляции тестов
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ToDoEntity.fetchRequest()
        do {
            if let items = try persistentContainer?.persistentContainer.viewContext.fetch(fetchRequest) {
                for item in items {
                    if let managedObject = item as? NSManagedObject {
                        persistentContainer?.persistentContainer.viewContext.delete(managedObject)
                    }
                }
                try persistentContainer?.persistentContainer.viewContext.save()
            }
        } catch {
            print("Failed to delete previous data: \(error)")
        }
    }
    
    override func tearDown() {
        // Сброс контекста после теста
        storageService = nil
        persistentContainer?.persistentContainer.viewContext.rollback()
        
        storageService = nil
        persistentContainer = nil
        super.tearDown()
    }
    
    func testLoadTodos() async {
        let todo = ToDoRecord(id: 1, todo: "Test Todo", description: "Test Description", date: Date(), completed: false)
        await storageService?.addTodo(todo)
        
        let todos = await storageService?.loadTodos()
        
        print("Loaded Todos: \(String(describing: todos))")

        XCTAssertNotNil(todos)
        XCTAssertEqual(todos?.count, 1)
        XCTAssertEqual(todos?.first?.todo, "Test Todo")
        XCTAssertEqual(todos?.first?.description, "Test Description")
    }
    
    func testSaveTodos() async {
        let todoRecords = [ToDoRecord(id: 1, todo: "Test Todo 1"), ToDoRecord(id: 2, todo: "Test Todo 1")]
        await storageService?.saveTodos(todoRecords)
        
        let todos = await storageService?.loadTodos()
        
        print("Save Todos: \(String(describing: todos))")

        XCTAssertNotNil(todos)
        XCTAssertEqual(todos?.count, 2)
        XCTAssertEqual(todos?.first?.todo, "Test Todo 1")
    }
    
    func testAddTodo() async {
        let todo = ToDoRecord(id: 1, todo: "Test Todo Add", description: "This is a test todo", date: Date(), completed: false)
        await storageService?.addTodo(todo)

        let todos = await storageService?.loadTodos()
        
        print("Add Todos: \(String(describing: todos))") // Для отладки

        XCTAssertNotNil(todos)
        XCTAssertEqual(todos?.count, 1)
        XCTAssertEqual(todos?.first?.todo, "Test Todo Add")
        XCTAssertEqual(todos?.first?.description, "This is a test todo")
    }
    
    func testUpdateTodo() async {
        let todo = ToDoRecord(id: 4, todo: "Test Todo Update")
        await storageService?.addTodo(todo) // Сначала добавляем, чтобы потом обновить
        
        let updatedTodo = ToDoRecord(id: 4, todo: "Updated Todo", description: "Updated Description", date: Date(), completed: true)
        await storageService?.updateTodo(updatedTodo) // Обновляем задачу
        
        let todos = await storageService?.loadTodos()
        
        print("Update Todos: \(String(describing: todos))")

        XCTAssertNotNil(todos)
        XCTAssertEqual(todos?.count, 1)
        XCTAssertEqual(todos?.first?.todo, "Updated Todo")
        XCTAssertEqual(todos?.first?.description, "Updated Description")
        XCTAssertEqual(todos?.first?.completed, true)
    }
    
    func testDeleteTodo() async {
        let todo = ToDoRecord(id: 5, todo: "Test Todo Delete")
        await storageService?.addTodo(todo)
        
        await storageService?.deleteTodo(5) // Удаляем задачу

        let todos = await storageService?.loadTodos()
        
        print("Delete Todos: \(String(describing: todos))")

        XCTAssertNotNil(todos)
        XCTAssertEqual(todos?.count, 0) // Проверяем, что задача удалена
    }
    
    func testGetNextId() async {
        let nextId = await storageService?.getNextId()
        XCTAssertEqual(nextId, 1) // Первоначально, у нас еще нет задач, ID должен быть 1
        
        let todo = ToDoRecord(id: 1, todo: "Test Todo 1")
        print("GetNextId Todo: \(String(describing: todo))")

        await storageService?.addTodo(todo)
        
        let nextIdAfterAdding = await storageService?.getNextId()
        XCTAssertEqual(nextIdAfterAdding, 2) // После добавления, следующий ID должен быть 2
    }
}

