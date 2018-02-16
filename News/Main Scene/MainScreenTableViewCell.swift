//
//  MainScreenTableViewCell.swift
//  News
//
//  Created by Sergey Roslyakov on 2/13/18.
//  Copyright © 2018 Sergey Roslyakov. All rights reserved.
//

import UIKit

class MainScreenTableViewCell: UITableViewCell {

    static let reuseID = "MainScreenCellReuseID"
    
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var viewsCountLabel: UILabel!
    
    private let dateFormatter = DateFormatter(withFormat: "dd MMMM YYYY, HH:mm", locale: "ru")
    
    func configure(with titleItem:Title) {
        let date = Date(timeIntervalSince1970: titleItem.publicationDate.milliseconds/1000)
        self.dateTimeLabel.text = dateFormatter.string(from: date)
        self.captionLabel.text = titleItem.text
        self.viewsCountLabel.text = "\(CoreDataManager.shared.titleViewsCount(byId: titleItem.id))"
    }
}
