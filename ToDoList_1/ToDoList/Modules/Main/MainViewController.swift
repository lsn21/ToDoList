//
//  MainViewController.swift
//  ToDoList
//
//  Created by SIARHEI LUKYANAU on 26.08.2024.
//

import UIKit

protocol MainViewProtocol: AnyObject {
    func displayData(data: [ToDoRecord])
    func saveNewTodo(_ newToDo: NewToDoEntity?)
}

class MainViewController: UITableViewController, MainViewProtocol {
    
    var presenter: MainPresenterProtocol!
    var configurator: MainConfiguratorProtocol = MainConfigurator()

    @IBOutlet var mainTableView: UITableView!
    
    var toDoRecords: [ToDoRecord]?

    let selfToNewToDoSegueName = "MainToNewToDoSegue"

    override func viewDidLoad() {
        super.viewDidLoad()

        configurator.configure(with: self)
        presenter.configureView()
        
        // Добавляем кнопку для добавления новых записей
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openNewTodo))
    }
    
    // Обработка отображения данных в таблице
    func displayData(data: [ToDoRecord]) {

        self.toDoRecords = data
        mainTableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = toDoRecords?.count ?? 0
        return count
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
            presenter.removeRecord(indexPath)
        }
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        presenter.switchChanged(sender)
    }
    
    @objc func openNewTodo() {
        presenter.openNewTodo()
    }
    
    func saveNewTodo(_ newToDo: NewToDoEntity?) {
        presenter.saveNewTodo(newToDo)
    }
}
