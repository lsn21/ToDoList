//
//  NewToDoViewController.swift
//  ToDoListMVC
//
//  Created by SIARHEI LUKYANAU on 27.08.2024.
//

import UIKit

class NewToDoViewController: UIViewController {

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    
    var delegate: MainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let todo = titleTextField.text
        let description = descriptionTextView.text
        delegate?.addNewTodo(todo: todo, description: description)
        self.dismiss(animated: true, completion: nil)
    }
}
