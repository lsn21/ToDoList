//
//  MainAssembly.swift
//  ToDoList
//
//  Created by SIARHEI LUKYANAU on 26.08.2024.
//

import Foundation
import UIKit

class MainAssembly {
    
    static func assembleModule() -> UIViewController {
        let view = MainViewController()
        let interactor = MainInteractor()
        let presenter = MainPresenter()
        let router = MainRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        interactor.output = presenter
        router.viewController = view

        return view
    }
}
