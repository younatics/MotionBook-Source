//
//  DetailPageViewController.swift
//  MotionBook
//
//  Created by Seungyoun Yi on 2017. 6. 9..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class DetailPageViewController : UICollectionViewController, NTTransitionProtocol, NTHorizontalPageViewControllerProtocol {
    var cameFromMain = false
    var cameFromBookmark = false
    var cameFromSearch = false
    
    var datas: [LibraryDataModel]?
    var pullOffset = CGPoint.zero
    
    init(collectionViewLayout layout: UICollectionViewLayout!, currentIndexPath indexPath: IndexPath) {
        super.init(collectionViewLayout:layout)
        self.automaticallyAdjustsScrollViewInsets = false
        
        if #available(iOS 10.0, *) {
            self.collectionView?.isPrefetchingEnabled = false
        }
        
        let collectionView :UICollectionView = self.collectionView!
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.white
        collectionView.register(DetailCell.self, forCellWithReuseIdentifier: DetailCell.ID)
        collectionView.setToIndexPath(indexPath)
        
        collectionView.performBatchUpdates({collectionView.reloadData()}, completion: { finished in
            if finished {
                collectionView.scrollToItem(at: indexPath,at:.centeredHorizontally, animated: false)
            }});
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView?.reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let _cell = cell as? DetailCell {
            _cell.gifView.animatedImage = nil
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailCell.ID, for: indexPath) as! DetailCell
        collectionCell.data = self.datas?[indexPath.row]
        
        collectionCell.pullAction = { offset in
            self.pullOffset = offset
            self.navigationController?.popViewController(animated: true)
        }
        
        collectionCell.bookmarkAction = { bookmarked in
            if self.cameFromBookmark && bookmarked == false {
                self.datas?.remove(at: indexPath.row)
                self.collectionView?.deleteItems(at: [indexPath])
                
                if self.datas?.count == 0 {
                    self.pullOffset = CGPoint.zero
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        collectionCell.layoutIfNeeded()
        return collectionCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        guard let _datas = datas else { return 0 }
        return _datas.count;
    }
    
    func transitionCollectionView() -> UICollectionView!{
        return collectionView
    }
        
    func pageViewCellScrollViewContentOffset() -> CGPoint{
        return self.pullOffset
    }
}
