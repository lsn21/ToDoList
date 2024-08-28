//
//  ToDoViewController.swift
//  ToDoList
//
//  Created by SIARHEI LUKYANAU on 27.08.2024.
//

import UIKit

protocol ToDoViewProtocol: AnyObject {
}

class ToDoViewController: UIViewController, ToDoViewProtocol {
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var completedSwitch: UISwitch!
    @IBOutlet var datePicker: UIDatePicker!

    var presenter: ToDoPresenterProtocol!
    var configurator: ToDoConfiguratorProtocol = ToDoConfigurator()

    weak var delegate: MainViewProtocol?
    var toDoRecord: ToDoRecord?
    private var isNew = true

    override func viewDidLoad() {
        super.viewDidLoad()

        configurator.configure(with: self)
        if let record = toDoRecord {
            isNew = false
            titleTextField.text = record.todo
            descriptionTextView.text = record.description
            completedSwitch.isOn = record.completed ?? false
            datePicker.date = record.date ?? Date()
        }
        else {
            completedSwitch.isOn = false
            datePicker.date = Date()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        presenter.dismissNewTodo()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let todo = titleTextField.text, !todo.isEmpty else { return }
        let id = toDoRecord?.id
        let description = descriptionTextView.text
        let date = datePicker.date
        let completed = completedSwitch.isOn
        let newToDo = ToDoRecord(id: id, todo: todo, description: description, date: date, completed: completed)
        delegate?.saveTodo(newToDo, isNew: isNew)
        presenter.dismissNewTodo()
    }
}
