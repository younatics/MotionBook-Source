//
//  DetailExampleButton.swift
//  MotionBook
//
//  Created by YiSeungyoun on 2017. 5. 14..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import SnapKit

public enum DetailExampleType {
    case normal
    case locked
    case disable
    case explainNormal
    case explainLocked
}

class DetailGithubButton: UIButton {
    var githubImageView: UIImageView!
    var githubArrowImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initView() {
        self.githubArrowImage = UIImageView(image: UIImage(named: "icEnter"))
        self.addSubview(githubArrowImage)

        self.githubArrowImage.snp.makeConstraints { (m) in
            m.right.equalTo(self)
            m.width.height.equalTo(14)
            m.centerY.equalTo(self)
        }

        self.githubImageView = UIImageView(image: UIImage(named: "icGithub"))
        self.addSubview(githubImageView)
        
        self.githubImageView.snp.makeConstraints { (m) in
            m.right.equalTo(self.githubArrowImage.snp.left).offset(-2)
            m.width.equalTo(42)
            m.height.equalTo(11)
            m.centerY.equalTo(self)
        }
    }
    
}


class DetailExampleButton: UIButton {
    var exampleImageView: UIImageView!
    var exampleLabel: UILabel!
    var type: DetailExampleType?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.exampleLabel.textColor = UIColor.white
                self.backgroundColor = UIColor(hexString: MainColor)
                
                guard let _type = type else { return }
                if _type == .normal || _type == .explainNormal {
                    self.exampleImageView.image = UIImage(named: "icExampleNormal_sel")
                } else {
                    self.exampleImageView.image = UIImage(named: "icExampleLock_sel")
                }
            } else {
                self.exampleLabel.textColor = UIColor(hexString: MainColor)
                self.backgroundColor = UIColor.white
                
                guard let _type = type else { return }
                if _type == .normal || _type == .explainNormal {
                    self.exampleImageView.image = UIImage(named: "icExampleNormal")
                } else {
                    self.exampleImageView.image = UIImage(named: "icExampleLock")
                }
            }
        }
    }
    
    func setType(type:DetailExampleType) {
        self.type = type
        switch type {
        case .normal:
            self.exampleImageView.image = UIImage(named: "icExampleNormal")
            self.layer.borderColor = UIColor(hexString: MainColor).cgColor
            self.exampleLabel.textColor = UIColor(hexString: MainColor)
            self.exampleLabel.text = "Example"
            self.backgroundColor = UIColor.white
            self.isEnabled = true

        case .locked:
            self.exampleImageView.image = UIImage(named: "icExampleLock")
            self.layer.borderColor = UIColor(hexString: MainColor).cgColor
            self.exampleLabel.textColor = UIColor(hexString: MainColor)
            self.exampleLabel.text = "Example"
            self.backgroundColor = UIColor.white
            self.isEnabled = true

        case .disable:
            self.exampleImageView.image = UIImage(named: "icExampleDim")
            self.layer.borderColor = UIColor(hexString: E1E4E8).cgColor
            self.exampleLabel.textColor = UIColor(hexString: E1E4E8)
            self.exampleLabel.text = "Example"
            self.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
            self.isEnabled = false
            
        case .explainNormal:
            self.exampleImageView.image = UIImage(named: "icExampleNormal")
            self.layer.borderColor = UIColor(hexString: MainColor).cgColor
            self.exampleLabel.textColor = UIColor(hexString: MainColor)
            self.exampleLabel.text = "Explain"
            self.backgroundColor = UIColor.white
            self.isEnabled = true
            
        case .explainLocked:
            self.exampleImageView.image = UIImage(named: "icExampleLock")
            self.layer.borderColor = UIColor(hexString: MainColor).cgColor
            self.exampleLabel.textColor = UIColor(hexString: MainColor)
            self.exampleLabel.text = "Explain"
            self.backgroundColor = UIColor.white
            self.isEnabled = true
        }
    }

    func initView() {
        self.layer.cornerRadius = 4
        self.layer.borderColor = UIColor(hexString: MainColor).cgColor
        self.layer.borderWidth = 1
        
        self.exampleLabel = UILabel()
        self.exampleLabel.font = UIFont.mediumSystemFont(ofSize: 11)
        self.exampleLabel.textColor = UIColor(hexString: MainColor)
        self.exampleLabel.text = "Example"
        self.addSubview(exampleLabel)
        
        self.exampleLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(self).offset(9)
            m.centerY.equalTo(self)
        }
        
        self.exampleImageView = UIImageView()
        self.addSubview(self.exampleImageView)
        
        self.exampleImageView.snp.makeConstraints { (m) in
            m.right.equalTo(self.exampleLabel.snp.left).offset(-2)
            m.width.height.equalTo(16)
            m.centerY.equalTo(self)
        }
        
    }
}
