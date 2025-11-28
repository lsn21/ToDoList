//
//  ToDoConfigurator.swift
//  ToDoList
//
//  Created by Siarhei Lukyanau on 17.08.25.
//  telegram: @LSN777, email: LSN21@YA.RU
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
