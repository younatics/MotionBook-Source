//
//  BookmarkView.swift
//  motion-book
//
//  Created by YiSeungyoun on 2017. 3. 26..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import RealmSwift
import SnapKit
import Pastel

class BookmarkView: UIView, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
    var nothingView: UIView!
    var libraryData = LibraryData()
    var pastelView: PastelView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.pastelView = PastelView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 64))
        self.pastelView.animationDuration = 2.0
        self.pastelView.setColors(GradationColors)
        self.pastelView.startAnimation()
        
        self.insertSubview(self.pastelView, at: 0)
        
        let titleLabel = UILabel()
        titleLabel.text = "Bookmarks"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.semiboldSystemFont(ofSize: 15)
        self.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(self)
            m.centerY.equalTo(pastelView).offset(10)
        }
        
        self.nothingView = UIView()
        self.nothingView.backgroundColor = UIColor.white
        self.addSubview(self.nothingView)
        
        self.nothingView.snp.makeConstraints { (m) in
            m.left.right.bottom.equalTo(self)
            m.top.equalTo(pastelView.snp.bottom)
        }

        
        let nothingImageView = UIImageView(image: UIImage(named: "icBookmarkEmpty"))
        self.nothingView.addSubview(nothingImageView)
        
        nothingImageView.snp.makeConstraints { (m) in
            m.width.height.equalTo(120)
            m.centerX.equalTo(self)
            m.top.equalTo(self.nothingView).offset(150)
        }
        
        let nothingLabel = UILabel()
        nothingLabel.font = UIFont.systemFont(ofSize: 14)
        nothingLabel.text = "Bookmark your favorite open source"
        nothingLabel.textColor = UIColor(hexString: TitleColor)
        self.nothingView.addSubview(nothingLabel)
        
        nothingLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(self)
            m.top.equalTo(nothingImageView.snp.bottom).offset(10)
        }
        
        self.tableView = UITableView()
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: "SearchViewCell", bundle: nil), forCellReuseIdentifier: SearchViewCell.ID)
        self.tableView.register(UINib.init(nibName: "BookmarkHeaderCell", bundle: nil), forCellReuseIdentifier: BookmarkHeaderCell.ID)
        self.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { (m) in
            m.top.equalTo(pastelView.snp.bottom)
            m.right.left.bottom.equalTo(self)
        }
        

    }
    
    func reloadDataAndCheckBookMark() {
        self.tableView.reloadData()
        
        if libraryData.getAllFavortieData().count > 0 {
            self.tableView.isHidden = false
            self.nothingView.isHidden = true
        } else {
            self.tableView.isHidden = true
            self.nothingView.isHidden = false
        }

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchViewCell.ID) as! SearchViewCell
        cell.gifView.animatedImage = nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == libraryData.getFavoriteArraySectionCount() - 1 {
            return libraryData.getFavoriteArrayCountWithSection(section: section) + 1
        } else {
            return libraryData.getFavoriteArrayCountWithSection(section: section)
        }
    }
    
    func isFooterTableviewCell(indexPath: IndexPath) -> Bool {
        if indexPath.section == libraryData.getFavoriteArraySectionCount() - 1 && indexPath.row == libraryData.getFavoriteArrayCountWithSection(section: indexPath.section) {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkHeaderCell.ID) as! BookmarkHeaderCell
        cell.titleString = libraryData.getFavoriteTitleOfArrayWithSection(section: section)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return libraryData.getFavoriteArraySectionCount()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isFooterTableviewCell(indexPath: indexPath) {
            return 50
        } else {
            return 175
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !self.isFooterTableviewCell(indexPath: indexPath) {
            let pageViewController =
                DetailPageViewController(collectionViewLayout: pageViewControllerLayout(), currentIndexPath:self.change(indexPath: indexPath))
            pageViewController.datas = Array(libraryData.getAllFavortieData())
            pageViewController.cameFromBookmark = true
            
            tableView.setToIndexPath(self.change(indexPath: indexPath))
            tableView.setChangedIndexPath(indexPath)
            self.parentViewController?.navigationController?.pushViewController(pageViewController, animated: true)
        }
    }
    
    func pageViewControllerLayout () -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        let itemSize  = (self.parentViewController?.navigationController!.isNavigationBarHidden)! ?
            CGSize(width: screenWidth, height: screenHeight) : CGSize(width: screenWidth, height: screenHeight-navigationHeaderAndStatusbarHeight)
        flowLayout.itemSize = itemSize
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        return flowLayout
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isFooterTableviewCell(indexPath: indexPath) {
            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchViewCell.ID) as! SearchViewCell
            cell.libData = libraryData.getFavoriteDataModelWithIndexPath(indexPath: indexPath, isFavorite: true)
            
            return cell
        }
    }
    
    func change(indexPath: IndexPath) -> IndexPath {
        let originSecion = indexPath.section
        
        var count = 0
        for i in 0..<originSecion {
            count += libraryData.getFavoriteArrayCountWithSection(section: i)
        }
        return IndexPath(row: count + indexPath.row, section: 0)
    }

}
