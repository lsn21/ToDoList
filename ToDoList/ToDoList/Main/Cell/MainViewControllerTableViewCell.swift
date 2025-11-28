//
//  MainViewControllerTableViewCell.swift
//  ToDoListMVC
//
//  Created by Siarhei Lukyanau on 17.08.25.
//  telegram: @LSN777, email: LSN21@YA.RU
//

import UIKit

class MainViewControllerTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var checkButton: UIButton!
    
    var delegate: MainPresenterProtocol?
    var selectedButton = false
    
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        selectedButton = !selectedButton
        delegate?.checkButtonTapped(sender, selected: selectedButton)
    }
    
}
