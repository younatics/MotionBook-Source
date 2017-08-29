//
//  SearchViewController.swift
//  motion-book
//
//  Created by YiSeungyoun on 2017. 3. 26..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import RealmSwift

class SearchExtraMainView: SearchMainView, YNSearchDelegate {
    var parentVC: UIViewController?
    let libraryData = LibraryData()
    
    var datas: Results<LibraryDataModel>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        let realm = try! Realm()
        let models = realm.objects(LibraryDataTypeModel.self).sorted(byKeyPath: "type")
        self.datas = realm.objects(LibraryDataModel.self)
        
        var dataArray = [Any]()
        guard let _datas = datas else { return }
        for data in _datas {
            let searchModel = LibraryDataModel()
            searchModel.author = data.author
            searchModel.detail = data.detail
            searchModel.gitStar = data.gitStar
            searchModel.title = data.title
            searchModel.type = data.type
            searchModel.updatedDate = data.updatedDate
            dataArray.append(searchModel)
        }
        
        var categories = [String]()
        for model in models {
            guard let type = model.type else { return }
            categories.append(type)
        }
        let ynSearch = YNSearch()
        
        ynSearch.setCategories(value: categories)
        self.ynSearchinit()
        
        self.initData(database: dataArray)
        
        self.ynSearchView.ynSearchListView.rowHeight = 150
        self.ynSearchView.ynSearchListView.estimatedRowHeight = 150
        self.ynSearchView.ynSearchListView.register(UINib.init(nibName: "SearchViewCell", bundle: nil), forCellReuseIdentifier: SearchViewCell.ID)
        self.delegate = self
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func ynSearchListViewDidScroll() {
        self.ynSearchTextfieldView.ynSearchTextField.endEditing(true)
    }
    

    func ynSearchHistoryButtonClicked(text: String) {
        self.changeView()

        self.ynSearchTextfieldView.ynSearchTextField.text = text
        self.ynSearchView.ynSearchListView.ynSearchTextFieldText = text
    }
    
    func ynCategoryButtonClicked(text: String) {
        self.changeView()

        self.ynSearchTextfieldView.ynSearchTextField.text = text
        self.ynSearchView.ynSearchListView.ynSearchCategoryString = text
    }
    
    func ynSearchListViewClicked(key: String) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "detail") as! DetailViewController
//        vc.libData = libraryData.getDataWith(title: key)
//        parentVC?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func ynSearchListViewClicked(object: Any) { }
    
    func ynSearchListView(_ ynSearchListView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.ynSearchView.ynSearchListView.dequeueReusableCell(withIdentifier: SearchViewCell.ID) as! SearchViewCell
        if indexPath.row < self.ynSearchView.ynSearchListView.searchResultDatabase.count {
            if let libData = self.ynSearchView.ynSearchListView.searchResultDatabase[indexPath.row] as? LibraryDataModel, let title = libData.title {
                cell.libData = libraryData.getDataWith(title: title)
            }
        }
        return cell
    }
    
    func ynSearchListView(_ ynSearchListView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pageViewController =
            DetailPageViewController(collectionViewLayout: pageViewControllerLayout(), currentIndexPath:indexPath)
        pageViewController.modalPresentationCapturesStatusBarAppearance = true
        pageViewController.cameFromSearch = true
        pageViewController.datas = self.getDataForDetail()
        ynSearchListView.setToIndexPath(indexPath)
        ynSearchListView.setChangedIndexPath(indexPath)
        self.parentViewController?.navigationController?.pushViewController(pageViewController, animated: true)

        if let libData = self.ynSearchView.ynSearchListView.searchResultDatabase[indexPath.row] as? LibraryDataModel, let _ = libData.title, let text = self.ynSearchTextfieldView.ynSearchTextField.text {
            self.ynSearchView.ynSearchListView.ynSearch.appendSearchHistories(value: text)

        }
    }
    
    func getDataForDetail() -> [LibraryDataModel] {
        guard let searchdatas = self.ynSearchView.ynSearchListView.searchResultDatabase as? [LibraryDataModel] else { return [LibraryDataModel]() }
        guard let realmDatas = datas else { return [LibraryDataModel]() }
        
        var allSearchData = [LibraryDataModel]()
        for i in 0..<searchdatas.count {
            guard let title = searchdatas[i].title else { return [LibraryDataModel]() }
            
            for realmData in realmDatas {
                guard let realmTitle = realmData.title else { return [LibraryDataModel]() }

                if realmTitle == title {
                    allSearchData.append(realmData)
                }
            }
        }
        return allSearchData
    }
    
    func pageViewControllerLayout () -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        let itemSize  = CGSize(width: screenWidth, height: screenHeight)
        flowLayout.itemSize = itemSize
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        return flowLayout
    }



}
