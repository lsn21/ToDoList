//
//  NewToDoViewController.swift
//  ToDoList
//
//  Created by SIARHEI LUKYANAU on 27.08.2024.
//

import UIKit

protocol NewToDoViewProtocol: AnyObject {
}

class NewToDoViewController: UIViewController, NewToDoViewProtocol {
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    
    var presenter: NewToDoPresenterProtocol!
    var configurator: NewToDoConfiguratorProtocol = NewToDoConfigurator()

    weak var delegate: MainViewProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configurator.configure(with: self)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        presenter.dismissNewTodo()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let todo = titleTextField.text, !todo.isEmpty else { return }
        let description = descriptionTextView.text
        let newToDo = NewToDoEntity(todo: todo, description: description)
        delegate?.saveNewTodo(newToDo)
        presenter.dismissNewTodo()
    }
}
