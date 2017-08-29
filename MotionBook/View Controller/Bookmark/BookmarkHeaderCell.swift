//
//  BookmarkHeaderCell.swift
//  MotionBook
//
//  Created by YiSeungyoun on 2017. 5. 7..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import Foundation

class BookmarkHeaderCell: UITableViewCell {
    static let ID = "BookmarkHeaderCell"

    @IBOutlet var titleLabel: UILabel!

    var titleString: String? {
        didSet {
            self.bind()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func bind() {
        titleLabel.text = titleString
    }
}
