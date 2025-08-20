//
//  MainViewController.swift
//  ToDoList
//
//  Created by Siarhei Lukyanau on 17.08.25.
//

import UIKit

protocol MainViewProtocol: AnyObject {
    func displayData(data: [ToDoRecord])
    func saveTodo(_ newToDo: ToDoRecord?, isNew: Bool)
    func showResults(data: [ToDoRecord])
    func showActionSheet(_ indexPath: IndexPath)
    func showShareActivity(with items: [Any])
}

class MainViewController: UIViewController, MainViewProtocol {
    
    var presenter: MainPresenterProtocol?
    var configurator: MainConfiguratorProtocol = MainConfigurator()
    
    @IBOutlet var mainTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var countLabel: UILabel!
    
    var toDoRecords: [ToDoRecord]?
    var actionSheet: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nc = navigationController {
            configurator.configure(with: self, navigationController: nc)
            presenter?.configureView()
        }
        initUI()
    }
    
    func initUI() {
        searchBar.delegate = self
        let placeholderText = "Поиск..."
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(named: "PlaceholderColor") as Any]
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
        
        let textField = searchBar.searchTextField
        textField.delegate = self
        textField.autocapitalizationType = .none
        textField.tintColor = .white
        textField.textColor = .white
        textField.backgroundColor = UIColor(named: "SearchBgColor")
        if let leftView = textField.leftView as? UIImageView {
            leftView.tintColor = UIColor(named: "ToDoYellowColor")//.white
        }
        textField.clearButtonTintColor = UIColor(named: "ToDoYellowColor")//.white
    }
    
    func showResults(data: [ToDoRecord]) {
        self.toDoRecords = data
        mainTableView.reloadData()
        countLabel.text = "\(toDoRecords?.count ?? 0) задач"
    }
    
    // Обработка отображения данных в таблице
    func displayData(data: [ToDoRecord]) {
        
        self.toDoRecords = data
        mainTableView.reloadData()
        countLabel.text = "\(toDoRecords?.count ?? 0) задач"
    }
    
    @IBAction func newTodoButtonTapped(_ sender: UIButton) {
        presenter?.openNewTodo()
    }
    
    func saveTodo(_ newToDo: ToDoRecord?, isNew: Bool) {
        presenter?.saveTodo(newToDo, isNew: isNew)
    }
    
    func showActionSheet(_ indexPath: IndexPath) {
        // Если actionSheet уже существует, просто возвращаемся
        if actionSheet != nil {
            return
        }

        // Создаем actionSheet
        actionSheet = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 40, height: 150))
        actionSheet?.backgroundColor = UIColor(named: "ActionSheetBgColor")
        actionSheet?.layer.cornerRadius = 12
        actionSheet?.alpha = 0 // Начальная прозрачность 0 для анимации

        let options = [("Редактировать", UIImage(named: "edit_icon")),
                       ("Поделиться", UIImage(named: "icon_export")),
                       ("Удалить", UIImage(named: "icon_trash"))]

        let lineImage = UIImage(named: "line_image")
        for (index, option) in options.enumerated() {
            let button = CustomButton(frame: CGRect(x: 16, y: index * 50, width: Int(actionSheet?.frame.width ?? 0) - 32, height: 50))
            button.setTitle(option.0, for: .normal)
            button.tag = index
            button.indexPath = indexPath
            if index == 2 {
                button.setTitleColor(UIColor(named: "ToDoRedColor"), for: .normal)
            } else {
                button.setTitleColor(UIColor(named: "BgColor"), for: .normal)
                let lineImageView = UIImageView()
                lineImageView.image = lineImage
                lineImageView.frame = CGRect(x: 0, y: (index + 1) * 50, width: Int(actionSheet?.frame.width ?? 0), height: 1)
                actionSheet?.addSubview(lineImageView)
            }
            button.contentHorizontalAlignment = .left
            
            let iconImageView = UIImageView(image: option.1?.withRenderingMode(.alwaysOriginal))
            iconImageView.frame = CGRect(x: (actionSheet?.frame.width ?? 0) - 48, y: 17, width: 16, height: 16)
            iconImageView.contentMode = .scaleAspectFit
            
            button.addSubview(iconImageView)
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            actionSheet?.addSubview(button)
        }
        
        actionSheet?.center = self.view.center
        self.view.addSubview(actionSheet ?? UIView())
        
        // Добавляем жест для закрытия actionSheet при нажатии вне его
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissActionSheet))
        self.view.addGestureRecognizer(tapGesture)
        
        // Анимация открытия
        UIView.animate(withDuration: 0.3, animations: {
            self.actionSheet?.alpha = 1
            self.actionSheet?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0) // Увеличиваем до нормального размера
        })
    }

    @objc func dismissActionSheet() {
        // Проверяем, существует ли actionSheet
        guard let actionSheet = actionSheet else { return }
        
        // Анимация закрытия
        UIView.animate(withDuration: 0.3, animations: {
            actionSheet.alpha = 0
            actionSheet.transform = CGAffineTransform(scaleX: 0.9, y: 0.9) // Уменьшаем размер
        }) { _ in
            actionSheet.removeFromSuperview() // Удаляем actionSheet из иерархии представлений
            self.actionSheet = nil // Удаляем ссылку на actionSheet
            
            // Удаляем жест для закрытия actionSheet
            if let gestureRecognizers = self.view.gestureRecognizers {
                for gesture in gestureRecognizers {
                    if let tapGesture = gesture as? UITapGestureRecognizer {
                        self.view.removeGestureRecognizer(tapGesture) // Удаляем жест
                        break // Удаляем только первый найденный жест
                    }
                }
            }
        }
    }

    func showShareActivity(with items: [Any]) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        // Для iPad
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func optionSelected(_ sender: CustomButton) {
        let indexPath = sender.indexPath ?? IndexPath()
        let index = indexPath.row
        let tag = sender.tag
        switch tag {
        case 0:
            if let toDoRecord = toDoRecords?[index] {
                presenter?.openEditTodo(toDoRecord)
            }
        case 1:
            if let toDoRecord = toDoRecords?[index] {
                presenter?.didTapShareButton(toDoRecord)
            }
        case 2:
            showAlertRemoveTapped(indexPath)

        default:
            break
        }
        print("\(sender.title(for: .normal) ?? "") выбрана")
        dismissActionSheet()
    }
    
    func showAlertRemoveTapped(_ indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Внимание!", message: "Вы действидельно хотите удалить эту запись?", preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            Task { @MainActor in
                self?.presenter?.removeRecord(indexPath)
            }
        }
        alertController.addAction(yesAction)

        let noAction = UIAlertAction(title: "Нет", style: .default)
        alertController.addAction(noAction)

        present(alertController, animated: true, completion: nil)
    }

    @objc func actionSheetButtonTapped(_ indexPath: IndexPath) {
        presenter?.didTapActionSheetButton(indexPath)
    }
}
 
extension MainViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            print("Текст удален")
            presenter?.configureView()
            searchBar.resignFirstResponder() // Скрываем клавиатуру
            countLabel.text = "\(toDoRecords?.count ?? 0) задач"
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.setTitleColor(UIColor(named: "ToDoYellowColor"), for: .normal)
        }
        let cancelButtonTitle = "Отмена"
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.setTitle(cancelButtonTitle, for: .normal)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Действие при нажатии на кнопку "Отмена"
        searchBar.text = "" // Очищаем текст
        presenter?.configureView()
        searchBar.resignFirstResponder() // Скрываем клавиатуру
        searchBar.showsCancelButton = false // Скрываем кнопку "Отмена"
    }
}

extension MainViewController: UITextFieldDelegate {
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Скрыть клавиатуру
        textField.resignFirstResponder()
        
        // Запустить поиск
        if let query = textField.text, !query.isEmpty {
            presenter?.search(query: query)
        }
        
        return true
    }
}

extension MainViewController: UITableViewDataSource {
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = toDoRecords?.count ?? 0
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MainViewControllerTableViewCell", for: indexPath) as? MainViewControllerTableViewCell {
            
            let index = indexPath.row
            if let toDoRecord = toDoRecords?[index] {
                
                cell.delegate = presenter
                
                let title = toDoRecord.todo ?? ""
                let completedString = NSMutableAttributedString(string: title)
                completedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: title.count))

                let notCompletedString = NSMutableAttributedString(string: title)

                if toDoRecord.completed ?? false {
                    cell.titleLabel.attributedText = completedString
                }
                else {
                    cell.titleLabel.attributedText = notCompletedString
                }

                var description = toDoRecord.description ?? ""
                if description.count == 0 {
                    description = title
                }
                cell.descriptionLabel.text = description
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yy"
                let date = toDoRecord.date ?? Date()
                
                cell.dateLabel.text = dateFormatter.string(from: date)
                let completed = toDoRecord.completed ?? false
                cell.selectedButton = completed
                if completed {
                    cell.checkButton.setImage(UIImage(named: "icon_check_selected"), for: .normal)
                }
                else {
                    cell.checkButton.setImage(UIImage(named: "icon_check_unselected"), for: .normal)
                }
                cell.checkButton.tag = toDoRecord.id ?? 0
            }
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        showActionSheet(indexPath)
    }
}

extension UITextField{
    
    var clearButton : UIButton{
        return (self.value(forKey: "_clearButton") as? UIButton) ?? UIButton()
    }
    
    var clearButtonTintColor: UIColor? {
           get {
               return clearButton.tintColor
           }
           set {
             var image = clearButton.imageView?.image
                
            if image == nil{
                image = UIImage(named: "clear_field")//this is custom image
            }
        
                image =  image?.withRenderingMode(.alwaysTemplate)
               clearButton.setImage(image, for: .normal)
               clearButton.tintColor = newValue
         
           }
       }
}

class CustomButton: UIButton {
    var indexPath: IndexPath?
}
