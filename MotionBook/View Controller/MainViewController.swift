//
//  GridCollectionViewController.swift
//  animator
//
//  Created by YiSeungyoun on 2017. 2. 7..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import SnapKit
import FLAnimatedImage
import RealmSwift
import Device

class MainViewController: BaseViewController, NTTransitionProtocol, NTWaterFallViewControllerProtocol, MainHeaderViewDelegate, YNTransitionProtocol, MainDelegate {
    let delegateHolder = NavigationControllerDelegate()
    var datas: Results<LibraryDataModel>?
    var libraryData = LibraryData()
    
    var settings = Settings()

    let width = UIScreen.main.bounds.size.width
    let height = UIScreen.main.bounds.size.height
    
    var mainView: MainCollectionView!
    var searchView: SearchExtraMainView!
    var bookmarkView: BookmarkView!
    var settingView: SettingView!
    
    var bottomButton1: UIButton!
    var bottomButton2: UIButton!
    var bottomButton3: UIButton!
    var bottomButton4: UIButton!
    
    var sectionTag = 0
    var tabTag = 0
    var categoryCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.delegate = delegateHolder
        self.view.backgroundColor = UIColor(red: 251/255, green: 251/255, blue: 251/255, alpha: 1)
        
        let didEnterForground = Notification.Name("did-enter-foreground")
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.didEnterForground), name: didEnterForground, object: nil)
        
        let libdata = LibraryData()
        self.categoryCount = libdata.getTitles().count
        
        self.dataRefreshed()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setViewControllers([self], animated: false)

        self.mainView.headerView.pastelView.startAnimation()
        self.searchView.ynSearchTextfieldView.pastelView.startAnimation()
        self.bookmarkView.pastelView.startAnimation()
        self.settingView.pastelView.startAnimation()

    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func dataRefreshed() {
        self.initView()

        self.datas = libraryData.getArrayWith(section: sectionTag, sorted: settings.getSortKey())
        self.mainView.headerView.initCategories()
        self.mainView.datas = self.datas
        
        guard let tag = settings.getShortCutKey() else { return }
        self.tabBarClickedMotion(tag: tag)
    }
    
    @objc func didEnterForground() {
        guard let tag = settings.getShortCutKey() else { return }
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewControllerWithHandler(completion: {
            self.tabBarClickedMotion(tag: tag)

        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.bookmarkView != nil {
            if self.bookmarkView.isHidden == false {
                self.bookmarkView.reloadDataAndCheckBookMark()
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    // MARK: MainHeaderViewDelegate
    func sortButtonClicked() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let popularAction = UIAlertAction(title: "Popular", style: .default) { (UIAlertAction) in
            self.settings.setSortKey(value: 0)
            self.reloadData()
        }
        
        let recentAction = UIAlertAction(title: "Recent", style: .default) { (UIAlertAction) in
            self.settings.setSortKey(value: 1)
            self.reloadData()
        }
        
        if settings.getSortKey() == 0 {
            popularAction.setValue(true, forKey: "checked")
        } else {
            recentAction.setValue(true, forKey: "checked")
        }

        alert.addAction(popularAction)
        alert.addAction(recentAction)

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
            self.mainView.headerView.sortButtonClosed()
        }))
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = self.mainView.headerView.sortButton.frame

        self.present(alert, animated: true, completion: {
        })
        alert.view.tintColor = UIColor(hexString: MainColor)
        
    }
    
    func reloadData() {
        self.mainView.headerView.sortButtonClosed()

        self.datas = libraryData.getArrayWith(section: sectionTag, sorted: settings.getSortKey())
        self.mainView.datas = self.datas
    }
    
    func categoryButtonClicked(_ tag: Int) {
        sectionTag = tag
        self.datas = libraryData.getArrayWith(section: tag, sorted: settings.getSortKey())
        self.mainView.datas = self.datas
    }
    
    func textfieldShouldReturn() -> Bool {
        if self.tabTag == 2 {
            return true
        } else {
            return false
        }
    }
    
    func tabBarClickedMotion(tag: Int) {
        self.tabTag = tag + 1

        switch tag {
        case 0:
            bottomButton1.imageView!.playBounceAnimation()
            
            bottomButton1.isSelected = true
            bottomButton2.isSelected = false
            bottomButton3.isSelected = false
            bottomButton4.isSelected = false
            
            self.mainView.isHidden = false
            self.searchView.isHidden = true
            self.bookmarkView.isHidden = true
            self.settingView.isHidden = true

        case 1:
            bottomButton2.imageView!.playBounceAnimation()
            
            bottomButton1.isSelected = false
            bottomButton2.isSelected = true
            bottomButton3.isSelected = false
            bottomButton4.isSelected = false
            
            self.mainView.isHidden = true
            self.searchView.isHidden = false
            self.bookmarkView.isHidden = true
            self.settingView.isHidden = true
            
            self.searchView.ynSearchView.ynSearchMainView.redrawSearchHistoryButtons()

        case 2:
            bottomButton3.imageView!.playBounceAnimation()
            
            bottomButton1.isSelected = false
            bottomButton2.isSelected = false
            bottomButton3.isSelected = true
            bottomButton4.isSelected = false
            
            self.mainView.isHidden = true
            self.searchView.isHidden = true
            self.bookmarkView.isHidden = false
            self.settingView.isHidden = true
            
            self.bookmarkView.reloadDataAndCheckBookMark()

        case 3:
            bottomButton4.imageView!.playBounceAnimation()
            
            bottomButton1.isSelected = false
            bottomButton2.isSelected = false
            bottomButton3.isSelected = false
            bottomButton4.isSelected = true
            
            self.mainView.isHidden = true
            self.searchView.isHidden = true
            self.bookmarkView.isHidden = true
            self.settingView.isHidden = false

        default:
            break
        }
        
        settings.removeShorCutKey()
    }
    
    @objc func tabBarClicked(_ sender: UIButton) {
        self.tabBarClickedMotion(tag: sender.tag - 101)
    }
    
    // MARK: - NTTransitionProtocol, NTWaterFallViewControllerProtocol
    func viewWillAppearWithPageIndex(_ pageIndex: NSInteger) {
        let currentIndexPath = IndexPath(row: pageIndex, section: 0)

        if !mainView.isHidden {
            let position: UICollectionViewScrollPosition =
                UICollectionViewScrollPosition.centeredHorizontally.intersection(.centeredVertically)
            guard let collectionView = self.mainView.collectionView else { return }
            
            collectionView.setToIndexPath(currentIndexPath)
            if pageIndex < 2 {
                collectionView.setContentOffset(CGPoint.zero, animated: false)
            } else {
                collectionView.scrollToItem(at: currentIndexPath, at: position, animated: false)
            }
            
        } else if !searchView.isHidden {
            guard let tableView = self.searchView.ynSearchView.ynSearchListView else { return }
            tableView.setToIndexPath(currentIndexPath)
            tableView.setChangedIndexPath(currentIndexPath)
            
            tableView.scrollToRow(at: currentIndexPath, at: .middle, animated: true)
            
        } else if !bookmarkView.isHidden {
            guard let tableView = self.bookmarkView.tableView else { return }
            tableView.setToIndexPath(self.change(pageIndex: pageIndex))
            tableView.setChangedIndexPath(currentIndexPath)
            
            tableView.scrollToRow(at: self.change(pageIndex: pageIndex), at: .middle, animated: true)
        }
    }
    
    func change(pageIndex: Int) -> IndexPath {
        var indexPath = IndexPath(row: 0, section: 0)
        var index = pageIndex
        var count = 0
        while index >= 0 {
            let sectionCount = libraryData.getFavoriteArrayCountWithSection(section: count)
            if sectionCount <= index && sectionCount > 0 {
                index -= sectionCount
                count += 1
            } else {
                indexPath = IndexPath(row: index, section: count)
                break
            }

        }
        return indexPath
    }

    
    
    func transitionCollectionView() -> UICollectionView! {
        return self.mainView.collectionView
    }
    
    func transitionSearchTableView() -> UITableView! {
        return self.searchView.ynSearchView.ynSearchListView
    }
    
    func transitionBookmarkTableView() -> UITableView! {
        return self.bookmarkView.tableView
    }
    
    // MARK: - Layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                if sectionTag != 0 {
                    self.mainView.headerView.categoryButtonClickedTag(tag: sectionTag - 1)
                }

            case UISwipeGestureRecognizerDirection.left:
                if sectionTag + 1 != categoryCount {
                    self.mainView.headerView.categoryButtonClickedTag(tag: sectionTag + 1)
                }

            default:
                break
            }
        }
    }

    func initView() {
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.mainView = MainCollectionView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        self.mainView.headerView.delegate = self
        self.view.addSubview(self.mainView)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.mainView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.mainView.addGestureRecognizer(swipeLeft)

        self.bookmarkView = BookmarkView()
        self.bookmarkView.isHidden = true
        self.view.addSubview(self.bookmarkView)
        
        self.bookmarkView.snp.makeConstraints { (m) in
            m.edges.equalTo(self.view)
        }
        
        self.searchView = SearchExtraMainView()
        self.searchView.parentVC = self
        self.searchView.mainDelegate = self
        self.searchView.isHidden = true
        self.view.addSubview(self.searchView)
        
        self.searchView.snp.makeConstraints { (m) in
            m.edges.equalTo(self.view)
        }
        
        self.settingView = SettingView()
        self.settingView.isHidden = true
        self.settingView.refreshDataAction = { () in
            let visibleCells = self.mainView.collectionView.indexPathsForVisibleItems
            
            for visibleCell in visibleCells {
                if let cell = self.mainView.collectionView.cellForItem(at: visibleCell) as? MainCollectionViewCell {
                    cell.gifView.animatedImage = nil
                }
            }
            
            if let visibleCells = self.searchView.ynSearchView.ynSearchListView.indexPathsForVisibleRows {
                for visibleCell in visibleCells {
                    if let cell = self.searchView.ynSearchView.ynSearchListView.cellForRow(at: visibleCell) as? SearchViewCell {
                        cell.gifView.animatedImage = nil
                    }
                }
            }
            
            if let visibleCells = self.bookmarkView.tableView.indexPathsForVisibleRows {
                for visibleCell in visibleCells {
                    if let cell = self.searchView.ynSearchView.ynSearchListView.cellForRow(at: visibleCell) as? SearchViewCell {
                        cell.gifView.animatedImage = nil
                    }
                }
            }
            
        }
        self.view.addSubview(self.settingView)
        
        self.settingView.snp.makeConstraints { (m) in
            m.edges.equalTo(self.view)
        }

        let bottomTabView = UIView()
        bottomTabView.backgroundColor = UIColor.init(red: 250/255, green: 250/255, blue: 250/255, alpha: 0.9)
        self.view.addSubview(bottomTabView)
        
        bottomTabView.snp.makeConstraints { (m) in
            m.left.right.bottom.equalTo(self.view)
            m.height.equalTo(DynamicBottomHeight)
        }
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(hexString: LineColor)
        self.view.addSubview(bottomLine)
        
        bottomLine.snp.makeConstraints { (m) in
            m.left.right.top.equalTo(bottomTabView)
            m.height.equalTo(0.5)
        }
        
        bottomButton1 = UIButton()
        bottomButton1.setImage(UIImage(named:"icTabbarsMainNormal"), for: .normal)
        bottomButton1.setImage(UIImage(named:"icTabbarsMainSelect"), for: .highlighted)
        bottomButton1.setImage(UIImage(named:"icTabbarsMainSelect"), for: .selected)
        bottomButton1.tag = 101
        bottomButton1.isSelected = true
        bottomButton1.addTarget(self, action: #selector(tabBarClicked(_:)), for: .touchUpInside)
        bottomTabView.addSubview(bottomButton1)
        self.view.addSubview(bottomButton1)
        
        bottomButton1.snp.makeConstraints { (m) in
            m.width.equalTo(width/4)
            m.height.equalTo(50)
            m.top.left.equalTo(bottomTabView)
        }
        
        bottomButton2 = UIButton()
        bottomButton2.setImage(UIImage(named:"icTabbarsSearchNormal"), for: .normal)
        bottomButton2.setImage(UIImage(named:"icTabbarsSearchSelect"), for: .highlighted)
        bottomButton2.setImage(UIImage(named:"icTabbarsSearchSelect"), for: .selected)
        bottomButton2.tag = 102
        bottomButton2.addTarget(self, action: #selector(tabBarClicked(_:)), for: .touchUpInside)
        bottomTabView.addSubview(bottomButton2)
        self.view.addSubview(bottomButton2)
        
        bottomButton2.snp.makeConstraints { (m) in
            m.left.equalTo(bottomButton1.snp.right)
            m.top.height.equalTo(bottomButton1)
            m.width.equalTo(width/4)
        }
        
        bottomButton3 = UIButton()
        bottomButton3.setImage(UIImage(named:"icTabbarsBookmarkNormal"), for: .normal)
        bottomButton3.setImage(UIImage(named:"icTabbarsBookmarkSelect"), for: .highlighted)
        bottomButton3.setImage(UIImage(named:"icTabbarsBookmarkSelect"), for: .selected)
        bottomButton3.tag = 103
        bottomButton3.addTarget(self, action: #selector(tabBarClicked(_:)), for: .touchUpInside)
        bottomTabView.addSubview(bottomButton3)
        self.view.addSubview(bottomButton3)
        
        bottomButton3.snp.makeConstraints { (m) in
            m.left.equalTo(bottomButton2.snp.right)
            m.top.height.equalTo(bottomButton1)
            m.width.equalTo(width/4)
        }
        
        bottomButton4 = UIButton()
        bottomButton4.setImage(UIImage(named:"icTabbarsSettingNormal"), for: .normal)
        bottomButton4.setImage(UIImage(named:"icTabbarsSettingSelect"), for: .highlighted)
        bottomButton4.setImage(UIImage(named:"icTabbarsSettingSelect"), for: .selected)
        bottomButton4.tag = 104
        bottomButton4.addTarget(self, action: #selector(tabBarClicked(_:)), for: .touchUpInside)
        bottomTabView.addSubview(bottomButton4)
        self.view.addSubview(bottomButton4)
        
        bottomButton4.snp.makeConstraints { (m) in
            m.right.top.equalTo(bottomTabView)
            m.height.equalTo(bottomButton1)
            m.width.equalTo(width/4)
        }
        

    }
}

