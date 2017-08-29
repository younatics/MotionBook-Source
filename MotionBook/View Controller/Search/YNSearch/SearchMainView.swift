//
//  YNSearchViewController.swift
//  YNSearch
//
//  Created by YiSeungyoun on 2017. 4. 11..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import SnapKit

open class SearchMainView: UIView, UITextFieldDelegate {
    open var delegate: YNSearchDelegate? {
        didSet {
            self.ynSearchView.delegate = delegate
        }
    }
    
    open var mainDelegate: MainDelegate?
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    open var ynSearchTextfieldView: YNSearchTextFieldView!
    open var ynSearchView: YNSearchView!
    
    open var ynSerach = YNSearch()
    
    open func ynSearchinit() {
        self.ynSearchTextfieldView = YNSearchTextFieldView(frame: CGRect(x: 0, y: 0, width: width, height: 64))
        self.ynSearchTextfieldView.ynSearchTextField.delegate = self
        self.ynSearchTextfieldView.ynSearchTextField.addTarget(self, action: #selector(ynSearchTextfieldTextChanged(_:)), for: .editingChanged)
        self.ynSearchTextfieldView.cancelButton.addTarget(self, action: #selector(ynSearchTextfieldcancelButtonClicked), for: .touchUpInside)
        self.ynSearchTextfieldView.textEraseButton.addTarget(self, action: #selector(ynSearchTextfieldTextEraseButtonClicked), for: .touchUpInside)
        self.addSubview(self.ynSearchTextfieldView)
        
        self.ynSearchView = YNSearchView(frame: CGRect(x: 0, y: 64, width: width, height: height-64))
        self.addSubview(self.ynSearchView)
    }
    
    open func setYNCategoryButtonType(type: YNCategoryButtonType) {
        self.ynSearchView.ynSearchMainView.setYNCategoryButtonType(type: .colorful)
    }
    
    open func initData(database: [Any]) {
        self.ynSearchView.ynSearchListView.initData(database: database)
    }
    
    // MARK: - YNSearchTextfield
    open func ynSearchTextfieldTextEraseButtonClicked() {
        self.ynSearchTextfieldView.ynSearchTextField.text = ""
        self.ynSearchTextfieldView.textEraseButton.isHidden = true
        self.ynSearchView.ynSearchListView.ynSearchTextFieldText = ""

    }
    
    open func ynSearchTextfieldcancelButtonClicked() {
        self.ynSearchTextfieldView.ynSearchTextField.text = ""

        self.ynSearchTextfieldView.ynSearchTextField.endEditing(true)
        self.ynSearchView.ynSearchMainView.redrawSearchHistoryButtons()
        self.ynSearchView.ynSearchListView.ynSearchTextFieldText = ""

        self.ynSearchView.ynSearchListView.isHidden = true
//        self.ynSearchView.ynSearchListView.alpha = 0
        
        UIView.animate(withDuration: 0.3, animations: {

            self.ynSearchTextfieldView.ynSearchTextField.snp.remakeConstraints { (m) in
                m.bottom.equalTo(self.ynSearchTextfieldView)
                m.top.bottom.equalTo(self.ynSearchTextfieldView.cancelButton)
                m.centerX.equalTo(self.ynSearchTextfieldView)
            }
            
            self.ynSearchTextfieldView.textEraseButton.alpha = 0
            self.ynSearchTextfieldView.cancelButton.alpha = 0
            self.ynSearchView.ynSearchMainView.alpha = 1
            self.ynSearchView.ynScrollView.isHidden = false

            self.layoutIfNeeded()

        }) { (true) in

            self.ynSearchTextfieldView.cancelButton.isHidden = true
            self.ynSearchTextfieldView.textEraseButton.isHidden = true
            
        }
    }
    open func ynSearchTextfieldTextChanged(_ textField: UITextField) {
        self.ynSearchView.ynSearchListView.ynSearchTextFieldText = textField.text
        
        guard let textCount = textField.text?.characters.count else { return }
        if textCount > 0 {
            self.ynSearchTextfieldView.textEraseButton.alpha = 1
            self.ynSearchTextfieldView.textEraseButton.isHidden = false

        } else {
            self.ynSearchTextfieldView.textEraseButton.isHidden = true
        }
    }
    
    // MARK: - UITextFieldDelegate
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return true }
        if !text.isEmpty {
            self.ynSerach.appendSearchHistories(value: text)
            self.ynSearchView.ynSearchMainView.redrawSearchHistoryButtons()
        }
        self.ynSearchTextfieldView.ynSearchTextField.endEditing(true)
        return true
    }
    
    func changeView() {
        if !self.ynSearchView.ynScrollView.isHidden {
            UIView.animate(withDuration: 0.3, animations: {
                self.ynSearchTextfieldView.ynSearchTextField.snp.remakeConstraints { (m) in
                    m.left.equalTo(self.ynSearchTextfieldView).offset(20)
                    m.top.bottom.equalTo(self.ynSearchTextfieldView.cancelButton)
                    m.right.equalTo(self.ynSearchTextfieldView).offset(-112)
                }
                
                self.ynSearchTextfieldView.cancelButton.alpha = 1
                self.ynSearchView.ynSearchMainView.alpha = 0
                self.ynSearchView.ynSearchListView.alpha = 1
                
                self.layoutIfNeeded()
            }) { (true) in

                self.ynSearchView.ynScrollView.isHidden = true
                self.ynSearchView.ynSearchListView.isHidden = false
                self.ynSearchTextfieldView.cancelButton.isHidden = false
                
            }
        }
    }
    
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let _maindelegate = mainDelegate else { return true }
        return _maindelegate.textfieldShouldReturn()
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        Log.contentview(action: "textFieldDidBeginEditing", location: self.parentViewController, id: nil)
        self.changeView()
        
        guard let textCount = textField.text?.characters.count else { return }
        if textCount > 0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.ynSearchTextfieldView.textEraseButton.alpha = 1
                
            }) { (true) in
                self.ynSearchTextfieldView.textEraseButton.isHidden = false
            }
            
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.ynSearchTextfieldView.textEraseButton.alpha = 0
                
            }) { (true) in
                self.ynSearchTextfieldView.textEraseButton.isHidden = true
            }
        }
        
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        
    }

    
}
