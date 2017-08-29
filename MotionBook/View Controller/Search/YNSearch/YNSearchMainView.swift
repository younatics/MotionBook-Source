//
//  YNSearchMainView.swift
//  YNSearch
//
//  Created by YiSeungyoun on 2017. 4. 16..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import SnapKit

open class YNSearchMainView: UIView {
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height

    open var categoryLabel: UILabel!
    open var ynCategoryButtons = [YNCategoryButton]()
    
    open var searchHistoryLabel: UILabel!
    open var bottomLine: UIView!
    open var ynSearchHistoryViews = [YNSearchHistoryView]()
    open var ynSearchHistoryButtons = [YNSearchHistoryButton]()
    open var clearHistoryButton: UIButton!

    
    var margin: CGFloat = 20
    open var delegate: YNSearchMainViewDelegate?
    
    open var ynSearch = YNSearch()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        guard let categories = YNSearch.shared.getCategories() else { return }
        self.initView(categories: categories)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    open func setYNCategoryButtonType(type: YNCategoryButtonType) {
        for ynCategoryButton in self.ynCategoryButtons {
            ynCategoryButton.type = type
        }
    }
    
    open func ynCategoryButtonClicked(_ sender: UIButton) {
        guard let text = ynCategoryButtons[sender.tag].categoryLabel.text else { return }
        self.delegate?.ynCategoryButtonClicked(text: text)
    }
    
    open func ynSearchHistoryButtonClicked(_ sender: UIButton) {
        guard let text = ynSearchHistoryButtons[sender.tag].textLabel.text else { return }
        self.delegate?.ynSearchHistoryButtonClicked(text: text)
    }
    
    open func clearHistoryButtonClicked() {
        ynSearch.setSearchHistories(value: [String]())
        self.redrawSearchHistoryButtons()
    }
    
    open func closeButtonClicked(_ sender: UIButton) {
        let string = ynSearchHistoryViews[sender.tag].ynSearchHistoryButton.textLabel.text
        guard let coreString = string else { return }
        ynSearch.deleteSearchHistories(value: coreString)
        self.redrawSearchHistoryButtons()
    }
    
    open func initView(categories: [String]) {
        self.categoryLabel = UILabel()
        self.categoryLabel.text = "CATEGORIES"
        self.categoryLabel.font = UIFont.semiboldSystemFont(ofSize: 12)
        self.categoryLabel.textColor = UIColor(hexString: GrayColor)
        self.addSubview(self.categoryLabel)
        
        self.categoryLabel.snp.makeConstraints { (m) in
            m.left.equalTo(self).offset(margin)
            m.top.equalTo(self).offset(30)
        }
        
        let categoryLine = UIView()
        categoryLine.backgroundColor = UIColor(hexString: E1E4E8)
        self.addSubview(categoryLine)
        
        categoryLine.snp.makeConstraints { (m) in
            m.left.right.equalTo(self)
            m.top.equalTo(self.categoryLabel.snp.bottom).offset(15)
            m.height.equalTo(0.5)
        }
        
        let font = UIFont.mediumSystemFont(ofSize: 11)
        let userAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName: UIColor(hexString: MainColor)]
        
        var formerWidth: CGFloat = margin
        var formerHeight: CGFloat = 80
        
        for i in 0..<categories.count {
            let size = categories[i].size(attributes: userAttributes)
            if i > 0 {
                formerWidth = ynCategoryButtons[i-1].frame.size.width + ynCategoryButtons[i-1].frame.origin.x + 5
                if formerWidth + size.width + margin*2 > UIScreen.main.bounds.width {
                    formerHeight += ynCategoryButtons[i-1].frame.size.height + 5
                    formerWidth = margin
                }
            }
            let button = YNCategoryButton(frame: CGRect(x: formerWidth, y: formerHeight, width: size.width + 36, height: size.height + 16))
            button.addTarget(self, action: #selector(ynCategoryButtonClicked(_:)), for: .touchUpInside)
            button.categoryLabel.text = categories[i]
            button.tag = i
            
            ynCategoryButtons.append(button)
            self.addSubview(button)
            
        }
        
        
    }
    
    open func redrawSearchHistoryButtons() {
        if self.searchHistoryLabel != nil {
            self.searchHistoryLabel.removeFromSuperview()
        }
        
        if self.bottomLine != nil {
            self.bottomLine.removeFromSuperview()
        }

        for ynSearchHistoryView in ynSearchHistoryViews {
            ynSearchHistoryView.removeFromSuperview()
        }
        ynSearchHistoryViews.removeAll()
        ynSearchHistoryButtons.removeAll()

        if self.clearHistoryButton != nil {
            self.clearHistoryButton.removeFromSuperview()
        }
        
        let histories = ynSearch.getSearchHistories() ?? [String]()
        
        if histories.count > 0 {
            guard let originY = ynCategoryButtons.last?.frame.origin.y, let heightY = ynCategoryButtons.last?.frame.height else { return }
            self.searchHistoryLabel = UILabel(frame: CGRect(x: margin, y: originY + heightY + 50 + 36, width: 107, height: 14.5))
            self.searchHistoryLabel.text = "SEARCH HISTORY"
            self.searchHistoryLabel.font = UIFont.semiboldSystemFont(ofSize: 12)
            self.searchHistoryLabel.textColor = UIColor(hexString: GrayColor)
            self.addSubview(self.searchHistoryLabel)
            
            self.bottomLine = UIView()
            self.bottomLine.backgroundColor = UIColor(hexString: E1E4E8)
            self.addSubview(self.bottomLine)
            
            self.bottomLine.snp.makeConstraints { (m) in
                m.top.equalTo(self.searchHistoryLabel.snp.bottom).offset(14.5)
                m.left.right.equalTo(self)
                m.height.equalTo(0.5)
            }
            
            let searchHistoryLabelOriginY: CGFloat = searchHistoryLabel.frame.origin.y + searchHistoryLabel.frame.height + 15
            
            for i in 0..<histories.count {
                let view = YNSearchHistoryView(frame: CGRect(x: 0, y: searchHistoryLabelOriginY + CGFloat(i * 48) , width: width , height: 48))
                view.ynSearchHistoryButton.addTarget(self, action: #selector(ynSearchHistoryButtonClicked(_:)), for: .touchUpInside)
                view.closeButton.addTarget(self, action: #selector(closeButtonClicked(_:)), for: .touchUpInside)
                
                view.ynSearchHistoryButton.textLabel.text = histories[histories.count - i - 1]
                view.ynSearchHistoryButton.tag = i
                view.closeButton.tag = i
                
                ynSearchHistoryViews.append(view)
                ynSearchHistoryButtons.append(view.ynSearchHistoryButton)
                self.addSubview(view)
            }
            
            self.clearHistoryButton = UIButton(frame: CGRect(x: screenWidth - 40 - 20, y: self.searchHistoryLabel.frame.origin.y, width: 40, height: 20))
            self.clearHistoryButton.setTitle("CLEAR", for: .normal)
            self.clearHistoryButton.titleLabel?.font = UIFont.mediumSystemFont(ofSize: 12)
            self.clearHistoryButton.setTitleColor(UIColor(hexString: MainColor), for: .normal)
            self.clearHistoryButton.setTitleColor(UIColor(hexString: MainColor).withAlphaComponent(0.3), for: .highlighted)
            self.clearHistoryButton.addTarget(self, action: #selector(clearHistoryButtonClicked), for: .touchUpInside)
            self.addSubview(clearHistoryButton)
            
            self.delegate?.ynSearchMainViewSearchHistoryChanged()

        }
        
    }
}
