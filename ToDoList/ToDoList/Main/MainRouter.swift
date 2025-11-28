//
//  MainRouter.swift
//  ToDoList
//
//  Created by Siarhei Lukyanau on 17.08.25.
//  telegram: @LSN777, email: LSN21@YA.RU
//

import Foundation
import UIKit

protocol MainRouterProtocol: AnyObject {
    func showToDoScene(_ editToDo: ToDoRecord?)
}

class MainRouter: MainRouterProtocol {
    
    weak var viewController: MainViewController?
    private var navigationController: UINavigationController?
    
    init(viewController: MainViewController, navigationController: UINavigationController) {
        self.viewController = viewController
        self.navigationController = navigationController
    }

    func showToDoScene(_ editToDo: ToDoRecord?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let newToDoVC = storyboard.instantiateViewController(withIdentifier: "ToDoViewController") as? ToDoViewController {
            newToDoVC.delegate = viewController
            newToDoVC.toDoRecord = editToDo
            if viewController != nil {
                if let nc = self.navigationController {
                    nc.pushViewController(newToDoVC, animated: true)
                }
            }
        }
    }
}
