//
//  MainHeaderView.swift
//  MotionBook
//
//  Created by Seungyoun Yi on 2017. 5. 2..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import SnapKit
import Pastel

protocol MainHeaderViewDelegate {
    func categoryButtonClicked(_ tag: Int)
    
    func sortButtonClicked()
}

class MainHeaderView: UIView, UIScrollViewDelegate {
    var delegate: MainHeaderViewDelegate?
    
    var titleLabel: UILabel!
    var categoryView: UIScrollView!
    var contentView: UIView!
    var categoryButtons = [UIButton]()
    var sortButton: UIButton!
    var sortImageView: UIImageView!
    var currentOffset: CGFloat = 0
    var menuLine: UIView!
    var pastelView: PastelView!

    
    let settings = Settings()
    
    var sortButtonOpend = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func sortButtonClicked() {
        self.sortButtonOpend = !self.sortButtonOpend
        
        if sortButtonOpend {
            self.sortButtonOpened()
        } else {
            self.sortButtonClosed()
        }
    }
    
    func sortButtonClosed() {
        self.sortButtonOpend = false

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.9,
            options: [],
            animations: {
                self.sortImageView.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi), 0.0, 0.0, 0.0);
                
        }, completion: { _ in
        })
    }
    
    func sortButtonOpened() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [],
            animations: {
                self.sortImageView.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi), 1.0, 0.0, 0.0)
        }, completion: { _ in
        })
        self.delegate?.sortButtonClicked()
    }
    
    func categoryButtonClickedTag(tag: Int) {
        Log.contentview(action: "categoryButtonClickedTag", location: self.parentViewController!, id: "\(tag)")
        settings.setCategory(value: tag)
        

        UIView.animate(withDuration: 0.2, animations: {
            self.menuLine.snp.remakeConstraints({ (m) in
                m.width.equalTo(self.categoryButtons[tag].frame.width - 25)
                m.centerX.equalTo(self.categoryButtons[tag])
                m.height.equalTo(1.5)
                m.bottom.equalTo(self.categoryButtons[tag])
            })
            
            let categoryButtonOriginX = self.categoryButtons[tag].frame.origin.x
            let categoryButtonWidth = self.categoryButtons[tag].frame.width
            let categoryViewWidth = self.categoryView.frame.width
            
            if self.currentOffset > categoryButtonOriginX {
                self.categoryView.contentOffset = CGPoint(x: categoryButtonOriginX, y: 0)
            }
            
            if self.categoryButtons[tag].frame.origin.x + categoryButtonOriginX > categoryViewWidth && self.currentOffset + categoryViewWidth < categoryButtonOriginX + categoryButtonWidth {
                self.categoryView.contentOffset = CGPoint(x: categoryButtonOriginX - categoryViewWidth + categoryButtonWidth, y: 0)
            }
            
            self.layoutIfNeeded()
            
        }) { (completed) in
            for categoryButton in self.categoryButtons {
                categoryButton.isSelected = false
            }

            self.categoryButtons[tag].isSelected = true
        }
        
        self.delegate?.categoryButtonClicked(tag)
    }
    
    func categoryButtonClicked(_ sender: UIButton) {
        let tag = sender.tag - 1000
        self.categoryButtonClickedTag(tag: tag)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentOffset = scrollView.contentOffset.x
    }
    
    override func layoutSubviews() {
        guard let lastButton = categoryButtons.last else { return }
        contentView.frame = CGRect(x: 0, y: 0, width: lastButton.frame.origin.x + lastButton.frame.width + 5 , height: 43)
        self.categoryView.contentSize = contentView.frame.size

    }
    
    func initCategories() {
        settings.setCategory(value: 0)

        let libData = LibraryData()
        let types = libData.getTitles()
        
        let font = UIFont.systemFont(ofSize: 15)
        let userAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName: UIColor(hexString: GrayColor)]
        
        
        for i in 0..<types.count {
            let size = types[i].size(attributes: userAttributes)
            
            let categoryButton = UIButton()
            categoryButton.setTitle(types[i], for: .normal)
            categoryButton.setTitleColor(UIColor(hexString: GrayColor), for: .normal)
            categoryButton.setTitleColor(UIColor(hexString: MainColor), for: .selected)
            categoryButton.setTitleColor(UIColor(hexString: MainColor), for: .highlighted)
            categoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            categoryButton.tag = i + 1000
            categoryButton.addTarget(self, action: #selector(categoryButtonClicked(_:)), for: .touchUpInside)
            categoryButtons.append(categoryButton)
            
            contentView.addSubview(categoryButton)
            
            if i > 0 {
                categoryButton.snp.makeConstraints({ (m) in
                    m.width.equalTo(size.width + 30)
                    m.height.equalTo(contentView)
                    m.left.equalTo(categoryButtons[i-1].snp.right)
                    m.centerY.equalTo(categoryView)
                })
            } else {
                categoryButton.isSelected = true
                
                categoryButton.snp.makeConstraints({ (m) in
                    m.width.equalTo(size.width + 30)
                    m.height.equalTo(contentView)
                    m.left.equalTo(contentView).offset(5)
                    m.centerY.equalTo(categoryView)
                })
                
            }
        }
    }
    
    func initGradationView() {
        self.pastelView = PastelView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        self.pastelView.animationDuration = 2.0
        self.pastelView.setColors(GradationColors)
        self.pastelView.startAnimation()
        
        self.insertSubview(self.pastelView, at: 0)
    }
    
    func initView() {
        self.clipsToBounds = true
        
        self.initGradationView()
        
        self.sortButton = UIButton()
        self.sortButton.backgroundColor = UIColor.white
        self.sortButton.addTarget(self, action: #selector(sortButtonClicked), for: .touchUpInside)

        self.addSubview(self.sortButton)
        
        self.sortButton.snp.makeConstraints { (m) in
            m.width.equalTo(50)
            m.height.equalTo(43)
            m.right.equalTo(self)
            m.bottom.equalTo(self)
        }
        
        sortImageView = UIImageView()
        sortImageView.image = UIImage(named: "icSort")
        self.sortButton.addSubview(sortImageView)
        
        sortImageView.snp.makeConstraints { (m) in
            m.width.height.equalTo(30)
            m.center.equalTo(self.sortButton)
        }
        
        let verticalLine = UIView()
        verticalLine.backgroundColor = UIColor(hexString: LineColor)
        self.addSubview(verticalLine)
        
        verticalLine.snp.makeConstraints { (m) in
            m.right.equalTo(self.sortButton.snp.left).offset(0.5)
            m.top.bottom.equalTo(self.sortButton)
            m.width.equalTo(0.5)
        }
        
        contentView = UIView()

        self.categoryView = UIScrollView()
        self.categoryView.delegate = self
        self.categoryView.showsVerticalScrollIndicator = false
        self.categoryView.showsHorizontalScrollIndicator = false
        self.categoryView.backgroundColor = UIColor.white
        self.categoryView.contentSize = CGSize(width: 500, height: 43)
        self.categoryView.addSubview(contentView)
        self.addSubview(self.categoryView)
        
        self.categoryView.snp.makeConstraints { (m) in
            m.left.bottom.equalTo(self)
            m.right.equalTo(self.sortButton.snp.left)
            m.height.equalTo(43)
        }
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(hexString: LineColor)
        self.addSubview(bottomLine)
        
        bottomLine.snp.makeConstraints { (m) in
            m.left.right.bottom.equalTo(self)
            m.height.equalTo(0.5)
        }
        
        self.titleLabel = UILabel()
        
        let string = "Motion,\nMake apps brilliant"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.0
        
        let attrString = NSMutableAttributedString(string: string)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        self.titleLabel.numberOfLines = 2
        self.titleLabel.attributedText = attrString
        self.titleLabel.font = UIFont.semiboldSystemFont(ofSize: 32)
        self.titleLabel.textColor = UIColor.white
        self.addSubview(titleLabel)
        
        self.titleLabel.snp.makeConstraints { (m) in
            m.left.equalTo(self).offset(20)
            m.bottom.equalTo(self.categoryView.snp.top).offset(-30)
        }
        
        if screenWidth <= 320 {
            self.titleLabel.snp.remakeConstraints { (m) in
                m.left.equalTo(self).offset(20)
                m.bottom.equalTo(self.categoryView.snp.top).offset(-15)
            }

        }

        menuLine = UIView()
        menuLine.layer.cornerRadius = 0.5
        menuLine.backgroundColor = UIColor(hexString: MainColor)
        contentView.addSubview(menuLine)
        
        menuLine.snp.makeConstraints({ (m) in
            m.width.equalTo(21)
            m.left.equalTo(17.5)
            m.height.equalTo(1.5)
            m.bottom.equalTo(self)
        })
        

    }
}
