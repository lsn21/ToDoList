//
//  MainViewController.swift
//  ToDoListMVC
//
//  Created by SIARHEI LUKYANAU on 26.08.2024.
//

import UIKit
import CoreData

class MainViewController: UITableViewController {
    
    @IBOutlet var mainTableView: UITableView!
    
    var toDoRecords: [ToDoRecord]?
    
    let url = "https://dummyjson.com/todos"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Загружаем данные при загрузке контроллера
        toDoRecords = StorageService.shared.loadTodos()
        
        // Если БД пуста, получаем данные с сервера
        if toDoRecords?.isEmpty == true {
            getToDoList()
        }
        
        // Добавляем кнопку для добавления новых записей
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openNewTodo))
    }
    
    // MARK: - Private methods
    
    func getToDoList() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            ServerService.shared.fetchToDoData(from: self?.url ?? "") { answer in
                guard let self = self else { return }
                
                if let answer = answer, let todos = answer.todos {
                    self.toDoRecords = todos
                    for i in 0..<todos.count {
                        if todos[i].date == nil {
                            self.toDoRecords?[i].date = Date()
                        }
                    }
                    StorageService.shared.saveTodos(self.toDoRecords)

                    // Обновление UI должно быть выполнено на главном потоке
                    DispatchQueue.main.async {
                        self.mainTableView.reloadData()
                    }
                } else {
                    print("Failed to fetch person data.")
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoRecords?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDo", for: indexPath) as! MainViewControllerTableViewCell
        
        let index = indexPath.row
        if let toDoRecord = toDoRecords?[index] {
            let todo = toDoRecord.todo ?? ""
            cell.titleLabel.text = todo
            cell.descriptionLabel.text = toDoRecord.description ?? todo
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            let date = toDoRecord.date ?? Date()
            
            cell.dateLabel.text = dateFormatter.string(from: date)
            cell.completedSwitch.isOn = toDoRecord.completed ?? false
            cell.completedSwitch.tag = toDoRecord.id ?? 0
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = indexPath.row
            let id = toDoRecords?[index].id ?? 0
            
            // Удалить из БД
            DispatchQueue.global(qos: .background).async {
                StorageService.shared.deleteTodo(id)
                
                // Удалить элемент из массива
                DispatchQueue.main.async { [weak self] in
                    self?.toDoRecords?.remove(at: index)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }

    // MARK: - Editing, Adding & Deleting Todos
    
    func getIndexById(_ id: Int) -> Int {
        return toDoRecords?.firstIndex(where: { $0.id == id }) ?? 0
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        let id = sender.tag
        let index = getIndexById(id)

        toDoRecords?[index].completed = sender.isOn
        DispatchQueue.global(qos: .background).async {
            StorageService.shared.updateTodo(self.toDoRecords?[index] ?? ToDoRecord())
        }
    }
    
    @objc func openNewTodo() {
        self.performSegue(withIdentifier: "MainToNewToDoSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainToNewToDoSegue" {
            let secondView = segue.destination as! NewToDoViewController
            secondView.delegate = self
        }
    }

    public func addNewTodo(todo: String?, description: String?) {
        let newId = StorageService.shared.getNextId()

        let newToDo = ToDoRecord(id: newId, todo: todo, description: description, date: Date(), completed: false)
        toDoRecords?.append(newToDo)

        DispatchQueue.global(qos: .background).async {
            StorageService.shared.addTodo(newToDo)
            
            DispatchQueue.main.async { [weak self] in
                self?.mainTableView.reloadData()
            }
        }
    }
}
