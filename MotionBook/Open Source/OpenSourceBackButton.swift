//
//  OpenSourceBackButton.swift
//  MotionBook
//
//  Created by YiSeungyoun on 2017. 6. 1..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit

class OpenSourceBackButton: UIButton {
    override open var isHighlighted: Bool {
        didSet {
            switch isHighlighted {
            case true:
                self.backgroundColor = UIColor(hexString: "D51351")
            case false:
                self.backgroundColor = UIColor(hexString: MainColor)
            }
        }
    }
    
}
