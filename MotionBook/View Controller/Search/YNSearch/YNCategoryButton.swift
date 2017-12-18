//
//  YNCategoryButton.swift
//  YNSearch
//
//  Created by Seungyoun Yi on 2017. 4. 12..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import SnapKit

public enum YNCategoryButtonType {
    case background
    case border
    case colorful
}

open class YNCategoryButton: UIButton {
    open var categoryLabel: UILabel!
    open var categoryImageView: UIImageView!
    
    open var type: YNCategoryButtonType? {
        didSet {
            guard let _type = type else { return }
            self.setType(type: _type)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initVIew()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open var isHighlighted: Bool {
        didSet {
            switch isHighlighted {
            case true:
                layer.borderColor = UIColor(hexString: MainColor).cgColor
                self.categoryLabel.textColor = UIColor(hexString: MainColor)
                self.categoryImageView.image = UIImage(named: "icCategoryHashtag")
                
            case false:
                layer.borderColor = UIColor(hexString: E1E4E8).cgColor
                self.categoryLabel.textColor = UIColor(hexString: "5C6774")
                self.categoryImageView.image = UIImage(named: "icCategoryHashtag_nor")
            }
        }
    }
    open func initVIew() {
        self.layer.borderColor = UIColor(hexString: E1E4E8).cgColor
        self.layer.borderWidth = 1
        
        self.categoryLabel = UILabel()
        self.categoryLabel.font = UIFont.mediumSystemFont(ofSize: 11)
        self.categoryLabel.textColor = UIColor(hexString: "5C6774")
        self.addSubview(self.categoryLabel)
        
        self.categoryLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(self).offset(8)
            m.centerY.equalTo(self)
        }
        
        self.categoryImageView = UIImageView(image: UIImage(named: "icCategoryHashtag_nor"))
        self.addSubview(self.categoryImageView)
        
        categoryImageView.snp.makeConstraints { (m) in
            m.width.height.equalTo(16)
            m.centerY.equalTo(self)
            m.right.equalTo(self.categoryLabel.snp.left)
        }
        
        self.layer.cornerRadius = self.frame.height * 0.1

    }
    
    open func setType(type: YNCategoryButtonType) {
        switch type {
        case .background:
            self.layer.borderColor = nil
            self.layer.borderWidth = 0
            self.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
            
        case .border:
            self.layer.borderColor = UIColor.darkGray.cgColor
            self.layer.borderWidth = 1
            
        case .colorful:
            self.layer.borderColor = nil
            self.layer.borderWidth = 0
            self.backgroundColor = randomColor()
        }
        
    }
    
    open func randomColor() -> UIColor {
        let colorArray = ["009999", "0099cc", "0099ff", "00cc99", "00cccc", "336699", "3366cc", "3366ff", "339966", "666666", "666699", "6666cc", "6666ff", "996666", "996699", "999900", "999933", "99cc00", "99cc33", "660066", "669933", "990066", "cc9900", "cc6600" , "cc3300", "cc3366", "cc6666", "cc6699", "cc0066", "cc0033", "ffcc00", "ffcc33", "ff9900", "ff9933", "ff6600", "ff6633", "ff6666", "ff6699", "ff3366", "ff3333"]
        
        let randomNumber = arc4random_uniform(UInt32(colorArray.count))
        return UIColor(hexString: colorArray[Int(randomNumber)])
    }
    

}
