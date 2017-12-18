//
//  NTWaterfallView.swift
//  MotionBook
//
//  Created by Seungyoun Yi on 2017. 6. 9..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import RealmSwift
import FLAnimatedImage
import MXParallaxHeader
import Device

let waterfallViewCellIdentify = "waterfallViewCellIdentify"

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        
        let fromVCConfromA = (fromVC as? NTTransitionProtocol)
        let fromVCConfromB = (fromVC as? NTWaterFallViewControllerProtocol)
        let fromVCConfromC = (fromVC as? NTHorizontalPageViewControllerProtocol)
        
        let toVCConfromA = (toVC as? NTTransitionProtocol)
        let toVCConfromB = (toVC as? NTWaterFallViewControllerProtocol)
        let toVCConfromC = (toVC as? NTHorizontalPageViewControllerProtocol)
        
//        if let vc = toVC as? MainViewController, let detailVc = fromVC as? DetailPageViewController {
//            if vc.bookmarkView.isHidden == false && detailVc.datas?.count == 0 {
//                return nil
//            }
//        }
        if((fromVCConfromA != nil)&&(toVCConfromA != nil)&&(
            (fromVCConfromB != nil && toVCConfromC != nil)||(fromVCConfromC != nil && toVCConfromB != nil))){
            let transition = NTTransition()
            transition.presenting = operation == .pop
            return transition
        } else {
            return nil
        }
        
    }
}

class MainCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    var datas: Results<LibraryDataModel>? {
        didSet {
            self.collectionView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                self.startAnimatingVisibleCells()
            }
        }
    }
    
    var collectionView: UICollectionView!
    var headerView: MainHeaderView!
    var libraryData = LibraryData() {
        didSet {
        }
    }
    
    let settings = Settings()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        headerView = MainHeaderView()
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: CHTCollectionViewWaterfallLayout())
        collectionView.parallaxHeader.view = headerView
        collectionView.parallaxHeader.height = 213
        collectionView.parallaxHeader.mode = .fill
        collectionView.parallaxHeader.minimumHeight = DynamicNavigationHeight
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: waterfallViewCellIdentify)
        collectionView.reloadData()

        self.addSubview(collectionView)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func startAnimatingVisibleCells() {
        if let visibleCells = collectionView.visibleCells as? [MainCollectionViewCell] {
            for visibleCell in visibleCells {
                visibleCell.isCell(needAnimating: true)
            }
        }
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startAnimatingVisibleCells()
    }
    
    // MARK: UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: waterfallViewCellIdentify, for: indexPath) as! MainCollectionViewCell
        collectionCell.isCell(needAnimating: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        guard let data = datas?[indexPath.row].pngData as Data? else { return CGSize() }
        let image = UIImage(data: data)
        
        guard let size = image?.size else { return CGSize(width: gridWidth, height: 300) }
        let imageHeight = size.height * gridWidth/size.width
        
        return CGSize(width: gridWidth, height: imageHeight + 58)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        guard let _datas = datas else { return UICollectionViewCell() }

        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: waterfallViewCellIdentify, for: indexPath) as! MainCollectionViewCell
        collectionCell.libData = _datas[indexPath.row]
        collectionCell.tag = ((settings.getCategory()+1) * 10000) + indexPath.row
        collectionCell.setNeedsLayout()
        return collectionCell
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let _datas = datas else { return 0 }
        return _datas.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pageViewController = DetailPageViewController(collectionViewLayout: pageViewControllerLayout(), currentIndexPath:indexPath)
        guard let _data = datas else { return }
        pageViewController.datas = Array(_data)
        pageViewController.modalPresentationCapturesStatusBarAppearance = true

        pageViewController.cameFromMain = true
        collectionView.setToIndexPath(indexPath)
        self.parentViewController?.navigationController?.pushViewController(pageViewController, animated: true)
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

