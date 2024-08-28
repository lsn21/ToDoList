//
//  MainRouter.swift
//  ToDoList
//
//  Created by SIARHEI LUKYANAU on 26.08.2024.
//

import Foundation
import UIKit

protocol MainRouterProtocol: AnyObject {
    func showToDoScene(_ editToDo: ToDoRecord?)
}

class MainRouter: MainRouterProtocol {
    
    weak var viewController: MainViewController!
    
    init(viewController: MainViewController) {
        self.viewController = viewController
    }

    func showToDoScene(_ editToDo: ToDoRecord?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newToDoVC = storyboard.instantiateViewController(withIdentifier: "ToDoViewController") as! ToDoViewController
        newToDoVC.delegate = viewController
        newToDoVC.toDoRecord = editToDo
        if let mainVC = viewController {
            mainVC.present(newToDoVC, animated: true, completion: nil)
        }
    }
}
