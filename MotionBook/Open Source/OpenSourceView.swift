//
//  OpenSourceProtocol.swift
//  MotionBook
//
//  Created by YiSeungyoun on 2017. 5. 18..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import SnapKit

var AssociatedOpenSourceHandler = "AssociatedOpenSourceHandler"
var AssociatedOpenSourceIntroHandler = "AssociatedOpenSourceIntroHandler"
var AssociatedOpenSourceisOpenedHandler = "AssociatedOpenSourceisOpenedHandler"

extension UIViewController {
    var openSourceIntroView: OpenSourceIntroView {
        get {
            return objc_getAssociatedObject(self, &AssociatedOpenSourceIntroHandler) as! OpenSourceIntroView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedOpenSourceIntroHandler, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var openSourceView: OpenSourceView {
        get {
            return objc_getAssociatedObject(self, &AssociatedOpenSourceHandler) as! OpenSourceView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedOpenSourceHandler, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var openSourceisOpened: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedOpenSourceisOpenedHandler) as! Bool
        }
        set {
            objc_setAssociatedObject(self, &AssociatedOpenSourceisOpenedHandler, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UIViewController {
    func initOpenSourceView(_ vc: UIViewController) {
        let settings = Settings()
        let window = UIApplication.shared.keyWindow

        if !settings.getOpenSourceIntroViewShown() {
            self.openSourceIntroView = OpenSourceIntroView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
            window?.addSubview(self.openSourceIntroView)
            self.openSourceIntroView.alpha = 0
            UIView.animate(withDuration: 0.2, animations: {
                self.openSourceIntroView.alpha = 1
            })
            settings.setOpenSourceIntroViewShown(value: true)
        }
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(doubleTap)
        
        self.openSourceisOpened = false

        self.openSourceView = OpenSourceView(frame: CGRect(x: 0, y: 0 , width: screenWidth, height: screenHeight), vc: vc)
        self.openSourceView.isHidden = true
        window?.addSubview(self.openSourceView)
    }
    
    func doubleTapped() {
        let window = UIApplication.shared.keyWindow
        window?.bringSubview(toFront: self.openSourceView)
        self.openSourceView.show()
    }

}

class OpenSourceView: UIView {
    var backButton: UIButton!
    var backButtonImageVIew: UIImageView!
    var backButtonLabel: UILabel!
    var parentVC: UIViewController?
    
    func show() {
        self.isHidden = false
        
        UIView.animate(withDuration: 0.5) { 
            self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.8,
            options: [],
            animations: {
                self.backButton.snp.remakeConstraints { (m) in
                    m.left.right.bottom.equalTo(self)
                    m.height.equalTo(100)
                }

                self.layoutIfNeeded()
                
        }, completion: { _ in
            
        })

    }
    
    func hide() {
        UIView.animate(withDuration: 0.5) {
            self.backgroundColor = UIColor.black.withAlphaComponent(0)
        }

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.8,
            options: [],
            animations: {
                self.backButton.snp.remakeConstraints { (m) in
                    m.left.right.bottom.equalTo(self)
                    m.height.equalTo(0)
                }
                
                self.layoutIfNeeded()
                
        }, completion: { _ in
            self.isHidden = true
        })
    }
    
    func tapped() {
        self.hide()
    }
    
    init(frame: CGRect, vc: UIViewController) {
        super.init(frame: frame)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.addGestureRecognizer(tap)

        self.zPosition = 1
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.parentVC = vc
        
        self.backButton = OpenSourceBackButton()
        self.backButton.backgroundColor = UIColor(hexString: MainColor)
        self.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        self.addSubview(self.backButton)
        
        self.backButton.snp.makeConstraints { (m) in
            m.left.right.bottom.equalTo(self)
            m.height.equalTo(0)
        }

        self.backButtonLabel = UILabel()
        self.backButtonLabel.text = "Back"
        self.backButtonLabel.textColor = UIColor.white
        self.backButtonLabel.font = UIFont.semiboldSystemFont(ofSize: 17)
        self.backButton.addSubview(self.backButtonLabel)
        
        self.backButtonLabel.snp.makeConstraints { (m) in
            m.center.equalTo(self.backButton)
        }
        
        self.backButtonImageVIew = UIImageView(image: UIImage(named: "icExampleBack"))
        self.backButton.addSubview(self.backButtonImageVIew)
        
        self.backButtonImageVIew.snp.makeConstraints { (m) in
            m.centerY.equalTo(self.backButton)
            m.right.equalTo(self.backButtonLabel.snp.left).offset(-2)
            m.width.height.equalTo(30)
        }
        
        
    }
    
    func backTapped() {
        guard let vc = self.parentVC else { return }
        vc.navigationController?.popViewController(animated: true)
        self.removeFromSuperview()
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class OpenSourceIntroView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func gotItButtonClicked() {
        self.removeFromSuperview()
    }
    
    func initView() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)

        let mainView = UIView()
        mainView.backgroundColor = UIColor.white
        mainView.cornerRadius = 4
        self.addSubview(mainView)
        
        mainView.snp.makeConstraints { (m) in
            m.center.equalTo(self)
            m.width.equalTo(300)
            m.height.equalTo(380)
        }
        
        let mainImageView = UIImageView(image: UIImage(named: "icDoublefingertap"))
        mainView.addSubview(mainImageView)
        
        mainImageView.snp.makeConstraints { (m) in
            m.width.height.equalTo(120)
            m.centerX.equalTo(mainView)
            m.top.equalTo(mainView).offset(40)
        }

        let titleLabel = UILabel()
        titleLabel.font = UIFont.semiboldSystemFont(ofSize: 21)
        titleLabel.textColor = UIColor(colorLiteralRed: 61/255, green: 69/255, blue: 77/255, alpha: 1)
        titleLabel.text = "Double finger Tap"
        mainView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(mainView)
            m.top.equalTo(mainImageView.snp.bottom).offset(30)
        }
        
        let subLabel = UILabel()
        subLabel.textColor = UIColor(hexString: TitleColor)
        subLabel.font = UIFont.systemFont(ofSize: 14)
        subLabel.numberOfLines = 2
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.3
        paragraphStyle.alignment = .center
        
        let attrString = NSMutableAttributedString(string: "Tap to access the main menu and go back")
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        subLabel.attributedText = attrString
        subLabel.sizeToFit()
        mainView.addSubview(subLabel)
        
        subLabel.snp.makeConstraints { (m) in
            m.left.equalTo(mainView).offset(54)
            m.right.equalTo(mainView).offset(-54)
            m.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        
        let gotItButton = UIButton()
        gotItButton.setTitle("Got It", for: .normal)
        gotItButton.titleLabel?.font = UIFont.semiboldSystemFont(ofSize: 17)
        gotItButton.setTitleColor(UIColor(hexString: MainColor), for: .normal)
        gotItButton.setTitleColor(UIColor(hexString: MainColor).withAlphaComponent(0.3), for: .highlighted)
        gotItButton.addTarget(self, action: #selector(gotItButtonClicked), for: .touchUpInside)
        self.addSubview(gotItButton)
        
        gotItButton.snp.makeConstraints { (m) in
            m.centerX.equalTo(self)
            m.bottom.equalTo(mainView).offset(-40)
        }
    }
}

