//
//  ToDoConfigurator.swift
//  ToDoList
//
//  Created by SIARHEI LUKYANAU on 27.08.2024.
//

import Foundation

protocol ToDoConfiguratorProtocol: AnyObject {
    func configure(with viewController: ToDoViewController)
}

class ToDoConfigurator: ToDoConfiguratorProtocol {
    
    func configure(with viewController: ToDoViewController) {
        let presenter = ToDoPresenter(view: viewController)
        let interactor = ToDoInteractor(presenter: presenter)
        let router = ToDoRouter(viewController: viewController)
        
        viewController.presenter = presenter
        presenter.interactor = interactor
        presenter.router = router
    }
}
