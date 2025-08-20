//
//  ToDoViewController.swift
//  ToDoList
//
//  Created by Siarhei Lukyanau on 17.08.25.
//

import UIKit

protocol ToDoViewProtocol: AnyObject {
}

class ToDoViewController: UIViewController, ToDoViewProtocol {
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var descriptionTextView: PlaceholderTextView!
    @IBOutlet weak var dateLabel: UILabel!

    var presenter: ToDoPresenterProtocol?
    var configurator: ToDoConfiguratorProtocol = ToDoConfigurator()

    weak var delegate: MainViewProtocol?
    var toDoRecord: ToDoRecord?
    private var isNew = true

    override func viewDidLoad() {
        super.viewDidLoad()

        configurator.configure(with: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        var date = Date()
        if let record = toDoRecord {
            isNew = false
            titleTextField.text = record.todo
            descriptionTextView.text = record.description
            date = record.date ?? Date()
        }
        dateLabel.text = dateFormatter.string(from: date)
        setupUI()
        setupKeyboard()
        self.dismissKeyboardL153()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = UIColor(named: "ToDoYellowColor")
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Назад"
    }
    
    func setupUI() {
        
        // Установка плейсхолдера
        if let placeholder = titleTextField.placeholder {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor(named: "PlaceholderColor") as Any,
                .font: UIFont(name: "SFProDisplay-Regular", size: 16) as Any
            ]
            titleTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }
        
        descriptionTextView.placeholder = "Введите описание задачи"
        descriptionTextView.placeholderFont = UIFont(name: "SFProDisplay-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        descriptionTextView.placeholderColor = UIColor(named: "PlaceholderColor") ?? .white
    }
    
    func setupKeyboard() {
        // Создание кнопки для закрытия клавиатуры
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let closeKeyboardButton = UIBarButtonItem(title: "Закрыть", style: .done, target: self, action: #selector(closeKeyboard))
        closeKeyboardButton.tintColor = UIColor(named: "ToDoYellowColor")
        // Добавление кнопки на панель
        toolbar.items = [flexibleSpace, closeKeyboardButton]
        
        // Установка toolbar как inputAccessoryView для titleTextField и descriptionTextView
//        titleTextField.inputAccessoryView = toolbar
        descriptionTextView.inputAccessoryView = toolbar
    }

    @objc func closeKeyboard() {
        // Закрытие клавиатуры
        titleTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        Task { @MainActor in
            guard let todo = titleTextField.text, !todo.isEmpty else { return }
            let id = toDoRecord?.id
            let description = descriptionTextView.text
            let date = Date()
            let newToDo = ToDoRecord(id: id, todo: todo, description: description, date: date)
            delegate?.saveTodo(newToDo, isNew: isNew)
            if let nc = self.navigationController {
                nc.popViewController(animated: true)
            }
        }
    }
}

extension ToDoViewController: UITextFieldDelegate {
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Скрыть клавиатуру
        textField.resignFirstResponder()
         
        return true
    }
}
