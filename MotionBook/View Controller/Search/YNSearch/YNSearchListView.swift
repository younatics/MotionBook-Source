//
//  YNSearchListView.swift
//  YNSearch
//
//  Created by YiSeungyoun on 2017. 4. 16..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import Highlighter

open class YNSearchListView: UITableView, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    open var database = [Any]()
    open var searchResultDatabase = [Any]()
    
    open var ynSearchListViewDelegate: YNSearchListViewDelegate?
    open var ynSearch = YNSearch()
    
    open var noSearchView: UIView!
    open var ynSearchTextFieldText: String? {
        didSet {
            guard let text = ynSearchTextFieldText else { return }
            
            let objectification = Objectification(objects: database, type: .values)
            let result = objectification.objects(contain: text)
            
            self.searchResultDatabase = result
            
            if result.isEmpty {
                self.noSearchView.isHidden = false
            } else {
                self.noSearchView.isHidden = true
            }

            if text.isEmpty {
                self.noSearchView.isHidden = true
                self.initData(database: database)
            }
            self.reloadData()
        }
    }
    
    open var ynSearchCategoryString: String? {
        didSet {
            guard let text = ynSearchCategoryString, let _database = database as? [LibraryDataModel] else { return }
            var array = [LibraryDataModel]()
            for value in _database {
                guard let type = value.type else { return }
                if type == text {
                    array.append(value)
                }
            }
            self.searchResultDatabase = array
            self.reloadData()

        }
    }
    
    public override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.initView()
    }
    
    open func initData(database: [Any]) {
        self.database = database
        self.searchResultDatabase = database
        self.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.startAnimatingVisibleCells()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func isFooterTableviewCell(indexPath: IndexPath) -> Bool {
        if indexPath.row == searchResultDatabase.count {
            return true
        }
        return false
    }
    
    func startAnimatingVisibleCells() {
        if let visibleCells = self.visibleCells as? [SearchViewCell] {
            for visibleCell in visibleCells {
                visibleCell.isCell(needAnimating: true)
            }
        }
    }
    
    // MARK: UIScrollViewDelegate
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startAnimatingVisibleCells()
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !self.isFooterTableviewCell(indexPath: indexPath) {
            guard let cell = self.ynSearchListViewDelegate?.ynSearchListView(tableView, cellForRowAt: indexPath) as? SearchViewCell else { return }
            cell.isCell(needAnimating: false)
        }
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isFooterTableviewCell(indexPath: indexPath) {
            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
            return cell
        } else {
            guard let cell = self.ynSearchListViewDelegate?.ynSearchListView(tableView, cellForRowAt: indexPath) as? SearchViewCell else { return UITableViewCell() }
            if let changedText = ynSearchTextFieldText {
                self.changeUILabelText(cell: cell, text: changedText, isCateogry: false)
            }
            if let changedText = ynSearchCategoryString {
                self.changeUILabelText(cell: cell, text: changedText, isCateogry: true)
            }
            return cell
        }
    }
    
    open func changeUILabelText(cell: SearchViewCell, text: String, isCateogry: Bool) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.3
        
        let highlightStyle = [NSAttributedStringKey.foregroundColor: UIColor(hexString:MainColor)]
        if !isCateogry {
            cell.descriptionLabel.highlight(text: text, normal: [NSAttributedStringKey.paragraphStyle: paragraphStyle], highlight: [NSAttributedStringKey.foregroundColor: UIColor(hexString:MainColor), NSAttributedStringKey.paragraphStyle: paragraphStyle])
            cell.authorLabel.highlight(text: text, normal: nil, highlight: highlightStyle)
            cell.titleLabel.highlight(text: text, normal: nil, highlight: highlightStyle)
            cell.dateLabel.highlight(text: text, normal: nil, highlight: highlightStyle)
            cell.starLabel.highlight(text: text, normal: nil, highlight: highlightStyle)

        }
        cell.categoryLabel.highlight(text: text, normal: nil, highlight: highlightStyle)
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultDatabase.count + 1
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isFooterTableviewCell(indexPath: indexPath) {
            return 50
        } else {
            return 175
        }
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !self.isFooterTableviewCell(indexPath: indexPath) {
            self.ynSearchListViewDelegate?.ynSearchListView(tableView, didSelectRowAt: indexPath)
        }
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.ynSearchListViewDelegate?.ynSearchListViewDidScroll()
    }
    
    open func initView() {
        self.delegate = self
        self.separatorStyle = .none
        self.dataSource = self
        self.backgroundColor = UIColor.white

        self.noSearchView = UIView()
        self.noSearchView.isHidden = true
        self.noSearchView.backgroundColor = UIColor.white
        self.addSubview(self.noSearchView)
        
        self.noSearchView.snp.makeConstraints { (m) in
            m.edges.equalTo(self)
        }
        
        let nothingImageView = UIImageView(image: UIImage(named: "icListEmpty"))
        self.noSearchView.addSubview(nothingImageView)
        
        nothingImageView.snp.makeConstraints { (m) in
            m.width.height.equalTo(120)
            m.centerX.equalTo(self)
            m.top.equalTo(self).offset(150)
        }
        
        let nothingLabel = UILabel()
        nothingLabel.font = UIFont.systemFont(ofSize: 14)
        nothingLabel.text = "No Search result"
        nothingLabel.textColor = UIColor(hexString: TitleColor)
        self.noSearchView.addSubview(nothingLabel)
        
        nothingLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(self)
            m.top.equalTo(nothingImageView.snp.bottom).offset(10)
        }

        
    }
}
