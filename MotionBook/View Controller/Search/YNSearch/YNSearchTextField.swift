//
//  YNSearchTextField.swift
//  YNSearch
//
//  Created by YiSeungyoun on 2017. 4. 11..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import SnapKit
import Pastel

open class YNSearchTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func initView() {
        self.leftViewMode = .always
        
        let searchImageViewWrapper = UIView(frame: CGRect(x: 0, y: 0, width: 26, height: 16))
        let searchImageView = UIImageView(frame: CGRect(x: 0, y: -1, width: 16, height: 16))
        let search = UIImage(named: "icSearch")
        searchImageView.image = search
        searchImageViewWrapper.addSubview(searchImageView)
        
        self.leftView = searchImageViewWrapper
        self.returnKeyType = .search
        self.attributedPlaceholder = NSAttributedString(string: "Find, lovely motion", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.8)])
        self.font = UIFont.systemFont(ofSize: 17)
        self.textColor = UIColor.white
        self.tintColor = UIColor.white
    }
}

open class YNSearchTextFieldView: UIView {
    open var ynSearchTextField: YNSearchTextField!
    open var pastelView: PastelView!
    open var cancelButton: UIButton!
    open var textEraseButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.pastelView = PastelView(frame: frame)
        self.pastelView.animationDuration = 2.0
        self.pastelView.setColors(GradationColors)
        self.pastelView.startAnimation()
        self.insertSubview(self.pastelView, at: 0)

        self.initView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func initView() {
        self.ynSearchTextField = YNSearchTextField()
        self.addSubview(self.ynSearchTextField)
        
        self.cancelButton = UIButton()
        self.cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        self.cancelButton.setTitleColor(UIColor.white, for: .normal)
        self.cancelButton.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .highlighted)
        self.cancelButton.setTitle("Cancel", for: .normal)
        self.cancelButton.isHidden = true

        self.addSubview(self.cancelButton)
        
        self.textEraseButton = UIButton()
        self.textEraseButton.setImage(UIImage(named: "icSearchDeleteWhite"), for: .normal)
        self.textEraseButton.setImage(UIImage(named: "icSearchDeletePress"), for: .highlighted)
        self.addSubview(self.textEraseButton)
        self.textEraseButton.isHidden = true

        self.cancelButton.snp.makeConstraints { (m) in
            m.right.equalTo(self).offset(-20)
            m.top.equalTo(self).offset(DynamicOffset)
            m.bottom.equalTo(self)
            m.width.equalTo(60)
        }
        
        self.textEraseButton.snp.makeConstraints { (m) in
            m.width.height.equalTo(16)
            m.centerY.equalTo(self.cancelButton)
            m.right.equalTo(self).offset(-86)
        }
        
        self.ynSearchTextField.snp.makeConstraints { (m) in
            m.top.bottom.equalTo(self.cancelButton)
            m.centerX.equalTo(self)
        }
        

    }

}
