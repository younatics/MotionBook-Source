//
//  BaseViewController.swift
//  animator
//
//  Created by YiSeungyoun on 2017. 2. 7..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

class NTNavigationController : UINavigationController {
    override func popViewController(animated: Bool) -> UIViewController? {
        self.setNavigationBarHidden(true, animated: false)
        let childrenCount = self.viewControllers.count
        if childrenCount > 1 {
            if let toViewController = self.viewControllers[childrenCount-2] as? NTWaterFallViewControllerProtocol, let popedViewController = self.viewControllers[childrenCount-1] as? UICollectionViewController, let popView  = popedViewController.collectionView {
                let toView = toViewController.transitionCollectionView()
                let indexPath = popView.fromPageIndexPath()
                toViewController.viewWillAppearWithPageIndex(indexPath.row)
                toView?.setToIndexPath(indexPath)
                return super.popViewController(animated: animated)
            }
        }
        return super.popViewController(animated: true)

    }
}
