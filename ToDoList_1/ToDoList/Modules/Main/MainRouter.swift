//
//  MainRouter.swift
//  ToDoList
//
//  Created by SIARHEI LUKYANAU on 26.08.2024.
//

import Foundation
import UIKit

protocol MainRouterProtocol: AnyObject {
    func showNewToDoScene()
}

class MainRouter: MainRouterProtocol {
    
    weak var viewController: MainViewController!
    
    init(viewController: MainViewController) {
        self.viewController = viewController
    }

    func showNewToDoScene() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newToDoVC = storyboard.instantiateViewController(withIdentifier: "NewToDoViewController") as! NewToDoViewController
//        let newToDoVC = NewToDoViewController()
        newToDoVC.delegate = viewController
        if let mainVC = viewController {
            mainVC.present(newToDoVC, animated: true, completion: nil) 
        }
    }
}
