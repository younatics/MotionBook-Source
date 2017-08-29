//
//  YNSearchButton.swift
//  YNSearch
//
//  Created by Seungyoun Yi on 2017. 4. 12..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit

open class YNSearchHistoryView: UIView {
    open var ynSearchHistoryButton: YNSearchHistoryButton!
    open var closeButton: UIButton!
    open var bottomLine: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func initView() {
        self.ynSearchHistoryButton = YNSearchHistoryButton(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        self.addSubview(ynSearchHistoryButton)
        
        self.closeButton = UIButton(frame: CGRect(x: self.frame.width - 50, y: (self.frame.height - 30)/2, width: 30, height: 30))
        let close = UIImage(named: "icListDelete")

        self.closeButton.setImage(close, for: .normal)
        self.addSubview(closeButton)
        
        self.bottomLine = UIView(frame: CGRect(x: 20, y: self.frame.height-0.5, width: self.frame.width - 40, height: 0.5))
        self.bottomLine.backgroundColor = UIColor(hexString: E1E4E8)
        self.addSubview(bottomLine)
        
    }
}

open class YNSearchHistoryButton: UIButton {
    open var textLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open var isHighlighted: Bool {
        didSet {
            switch isHighlighted {
            case true:
                self.backgroundColor = UIColor(hexString: "efefef")
            case false:
                self.backgroundColor = UIColor.white
            }
        }
    }
    
    open func initView() {
        self.textLabel = UILabel(frame: CGRect(x: 20, y: 0, width: self.frame.width - 20, height: self.frame.height))
        self.textLabel.font = UIFont.systemFont(ofSize: 14)
        self.textLabel.textColor = UIColor(hexString: "5C6774")
        self.addSubview(textLabel)
        
    }

}

