//
//  MainConfigurator.swift
//  IBRCurrencyConverter
//
//  Created by Ibrakhim Nikishin on 01.05.2018.
//  Copyright © 2018 Loftymoon. All rights reserved.
//

import Foundation
import UIKit

protocol MainConfiguratorProtocol: AnyObject {
    func configure(with viewController: MainViewController)
}

class MainConfigurator: MainConfiguratorProtocol {
    
    func configure(with viewController: MainViewController) {
        let presenter = MainPresenter(view: viewController)
        let interactor = MainInteractor(presenter: presenter)
        let router = MainRouter(viewController: viewController)
        
        viewController.presenter = presenter
        presenter.interactor = interactor
        presenter.router = router
    }
}
