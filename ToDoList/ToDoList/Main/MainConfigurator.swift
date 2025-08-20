//
//  ToDoRecord.swift
//  ToDoListMVC
//
//  Created by Siarhei Lukyanau on 17.08.25.
//

import Foundation
import UIKit

protocol MainConfiguratorProtocol: AnyObject {
    func configure(with viewController: MainViewController, navigationController: UINavigationController)
}

class MainConfigurator: MainConfiguratorProtocol {
    
    func configure(with viewController: MainViewController, navigationController: UINavigationController) {
        let presenter = MainPresenter(view: viewController)
        let interactor = MainInteractor(presenter: presenter)
        let router = MainRouter(viewController: viewController, navigationController: navigationController)
        
        viewController.presenter = presenter
        presenter.interactor = interactor
        interactor.output = presenter
        presenter.router = router
    }
}
