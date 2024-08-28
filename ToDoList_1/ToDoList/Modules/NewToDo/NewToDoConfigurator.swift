//
//  NewToDoConfigurator.swift
//  ToDoList
//
//  Created by SIARHEI LUKYANAU on 27.08.2024.
//

import Foundation

protocol NewToDoConfiguratorProtocol: AnyObject {
    func configure(with viewController: NewToDoViewController)
}

class NewToDoConfigurator: NewToDoConfiguratorProtocol {
    
    func configure(with viewController: NewToDoViewController) {
        let presenter = NewToDoPresenter(view: viewController)
        let interactor = NewToDoInteractor(presenter: presenter)
        let router = NewToDoRouter(viewController: viewController)
        
        viewController.presenter = presenter
        presenter.interactor = interactor
        presenter.router = router
    }
}
