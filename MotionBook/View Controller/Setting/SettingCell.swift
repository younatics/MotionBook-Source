//
//  DonationCell.swift
//  MotionBook
//
//  Created by YiSeungyoun on 2017. 5. 1..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import SnapKit

class SettingHeaderCell: UITableViewCell {
    static let ID = "SettingHeaderCell"
    
    var titleLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor(colorLiteralRed: 250/255, green: 250/255, blue: 250/255, alpha: 0.9)
        
        let topLine = UIView()
        topLine.backgroundColor = UIColor(hexString: E1E4E8)
        self.addSubview(topLine)
        
        topLine.snp.makeConstraints { (m) in
            m.left.right.top.equalTo(self)
            m.height.equalTo(0.5)
        }
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.semiboldSystemFont(ofSize: 12)
        titleLabel.textColor = UIColor(hexString: GrayColor)
        self.addSubview(self.titleLabel)
        
        self.titleLabel.snp.makeConstraints { (m) in
            m.left.equalTo(self).offset(20)
            m.bottom.equalTo(self).offset(-15)
        }
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(hexString: E1E4E8)
        self.addSubview(bottomLine)
        
        bottomLine.snp.makeConstraints { (m) in
            m.left.right.bottom.equalTo(self)
            m.height.equalTo(0.5)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SettingCell: UITableViewCell {
    static let ID = "SettingCell"
    
    var settingLabel: UILabel!
    var settingImageView: UIImageView!
    
    var bottomLine: UIView!
    var bottomEndLine: UIView!
    
    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.backgroundColor = UIColor(hexString: "efefef")
        } else {
            self.backgroundColor = UIColor.white
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none

        settingLabel = UILabel()
        settingLabel.font = UIFont.systemFont(ofSize: 15)
        settingLabel.textColor = UIColor(hexString: TitleColor)
        self.addSubview(self.settingLabel)
        
        self.settingLabel.snp.makeConstraints { (m) in
            m.left.equalTo(self).offset(20)
            m.right.equalTo(self).offset(20)
            m.centerY.equalTo(self)
        }
        
        settingImageView = UIImageView(image: UIImage(named: "icEnter"))
        self.addSubview(self.settingImageView)
        
        self.settingImageView.snp.makeConstraints { (m) in
            m.right.equalTo(self).offset(-20)
            m.width.height.equalTo(14)
            m.centerY.equalTo(self)
        }
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(hexString: E1E4E8)
        bottomLine.isHidden = true
        self.addSubview(bottomLine)
        
        bottomLine.snp.makeConstraints { (m) in
            m.bottom.equalTo(self)
            m.left.equalTo(self).offset(20)
            m.right.equalTo(self).offset(-20)
            m.height.equalTo(0.5)
        }
        
        bottomEndLine = UIView()
        bottomEndLine.backgroundColor = UIColor(hexString: E1E4E8)
        bottomEndLine.isHidden = true
        self.addSubview(bottomEndLine)
        
        bottomEndLine.snp.makeConstraints { (m) in
            m.bottom.left.right.equalTo(self)
            m.height.equalTo(0.5)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
