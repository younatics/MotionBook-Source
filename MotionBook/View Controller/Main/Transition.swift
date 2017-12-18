//
//  NTTransition.swift
//  PinterestSwift
//
//  Created by Nicholas Tau on 7/2/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

import UIKit
import Device

let animationDuration = 0.35

class NTTransition : NSObject, UIViewControllerAnimatedTransitioning {
    var presenting = false
    let settings = Settings()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval{
        return animationDuration
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as UIViewController? else { return }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as UIViewController? else { return }
        
        if !presenting {
            if let fromVC = fromViewController as? MainViewController, fromVC.mainView.isHidden {
                if !fromVC.bookmarkView.isHidden {
                    self.tableTransition(fromViewController: fromViewController, toViewController: toViewController, transitionContext: transitionContext, isBookmarkTransition: true)
                } else {
                    self.tableTransition(fromViewController: fromViewController, toViewController: toViewController, transitionContext: transitionContext, isBookmarkTransition: false)
                }
            } else {
                self.collectionTransition(fromViewController: fromViewController, toViewController: toViewController, transitionContext: transitionContext)
            }
        } else {
            if let fromVC = fromViewController as? DetailPageViewController, !fromVC.cameFromMain {
                if fromVC.cameFromBookmark {
                    self.tableTransition(fromViewController: fromViewController, toViewController: toViewController, transitionContext: transitionContext, isBookmarkTransition: true)
                } else {
                    self.tableTransition(fromViewController: fromViewController, toViewController: toViewController, transitionContext: transitionContext, isBookmarkTransition: false)
                }
            } else {
                self.collectionTransition(fromViewController: fromViewController, toViewController: toViewController, transitionContext: transitionContext)
            }
        }
        
    }
    
    func tableTransition(fromViewController: UIViewController, toViewController: UIViewController, transitionContext: UIViewControllerContextTransitioning, isBookmarkTransition: Bool) {
        let containerView = transitionContext.containerView
        containerView.backgroundColor = UIColor.white
        var offsetY: CGFloat = 105
        
        if presenting {
            let toView = toViewController.view!
            containerView.addSubview(toView)
            toView.isHidden = true
            
            var waterFallView = UITableView()
            if isBookmarkTransition {
                waterFallView = (toViewController as! YNTransitionProtocol).transitionBookmarkTableView()!
                waterFallView.reloadData()
            } else {
                waterFallView = (toViewController as! YNTransitionProtocol).transitionSearchTableView()!
            }
            
            waterFallView.layoutIfNeeded()
            
            let changedIndexPath = waterFallView.toIndexPath()

            if let gridView = waterFallView.cellForRow(at: changedIndexPath) as? SearchViewCell {
                let leftUpperPoint = gridView.convert(CGPoint(x: gridView.gifView.frame.origin.x, y: gridView.gifView.frame.origin.y), to: toViewController.view)
                
                let snapShot = gridView.snapShotForTransition()
                let animationScale = (screenWidth-40)/(snapShot?.frame.width)!
                
                snapShot?.transform = CGAffineTransform(scaleX: animationScale, y: animationScale)
                
                let pullOffsetY = (fromViewController as! NTHorizontalPageViewControllerProtocol).pageViewCellScrollViewContentOffset().y
                snapShot?.origin(CGPoint(x: 20, y: -pullOffsetY+offsetY))
                containerView.addSubview(snapShot!)
                
                toView.isHidden = false
                toView.alpha = 0
                toView.transform = (snapShot?.transform)!
                toView.frame = CGRect(x: -(leftUpperPoint.x * animationScale),y: -((leftUpperPoint.y-offsetY) * animationScale+pullOffsetY+offsetY),
                                      width: toView.frame.size.width, height: toView.frame.size.height)
                let whiteViewContainer = UIView(frame: screenBounds)
                whiteViewContainer.backgroundColor = UIColor.white
                containerView.addSubview(snapShot!)
                containerView.insertSubview(whiteViewContainer, belowSubview: toView)
                
                UIView.animate(withDuration: animationDuration, animations: {
                    snapShot?.transform = CGAffineTransform.identity
                    snapShot?.frame = CGRect(x: leftUpperPoint.x, y: leftUpperPoint.y, width: (snapShot?.frame.size.width)!, height: (snapShot?.frame.size.height)!)
                    toView.transform = CGAffineTransform.identity
                    toView.frame = CGRect(x: 0, y: 0, width: toView.frame.size.width, height: toView.frame.size.height)
                    toView.alpha = 1
                }, completion:{finished in
                    if finished {
                        snapShot?.removeFromSuperview()
                        whiteViewContainer.removeFromSuperview()
                        transitionContext.completeTransition(true)
                    }
                })
            } else {
                toView.isHidden = false
                toView.alpha = 0
                toView.frame = CGRect(x: 0, y: 0, width: toView.frame.size.width, height: toView.frame.size.height)
                
                UIView.animate(withDuration: animationDuration, animations: {
                    toView.alpha = 1

                }, completion:{finished in
                    if finished {
                        transitionContext.completeTransition(true)

                    }
                })
            }
        } else {
            // 들어갈 경우
            let fromView = fromViewController.view!
            let toView = toViewController.view
            
            var waterFallView = UITableView()
            if isBookmarkTransition {
                waterFallView = (fromViewController as! YNTransitionProtocol).transitionBookmarkTableView()!
            } else {
                waterFallView = (fromViewController as! YNTransitionProtocol).transitionSearchTableView()!
            }

            let pageView : UICollectionView = (toViewController as! NTTransitionProtocol).transitionCollectionView()
            
            containerView.addSubview(fromView)
            containerView.addSubview(toView!)
            
            let indexPath = waterFallView.toIndexPath()
            let changedIndexPath = waterFallView.changedIndexPath()
            
            if Device.version() == .iPhoneX {
                offsetY = 130
            }
            

            let gridView = waterFallView.cellForRow(at: changedIndexPath) as! SearchViewCell
            let leftUpperPoint = gridView.convert(CGPoint(x: gridView.gifView.frame.origin.x, y: gridView.gifView.frame.origin.y), to: nil)

            pageView.isHidden = true
            pageView.scrollToItem(at: indexPath, at:.centeredHorizontally, animated: false)
            
            let offsetStatuBar : CGFloat = fromViewController.navigationController!.isNavigationBarHidden ? 0.0 : statubarHeight
            let snapShot = gridView.snapShotForTransition()
            let animationScale = (screenWidth-40)/(snapShot?.frame.width)!

            containerView.addSubview(snapShot!)
            snapShot?.origin(leftUpperPoint)
            UIView.animate(withDuration: animationDuration, animations: {
                snapShot?.transform = CGAffineTransform(scaleX: animationScale,
                                                        y: animationScale)
                snapShot?.frame = CGRect(x: 20, y: offsetY, width: (snapShot?.frame.size.width)!, height: (snapShot?.frame.size.height)!)
                
                fromView.alpha = 0
                fromView.transform = (snapShot?.transform)!
                fromView.frame = CGRect(x: -(leftUpperPoint.x)*animationScale,
                                        y: -(leftUpperPoint.y-offsetStatuBar)*animationScale+offsetStatuBar,
                                        width: fromView.frame.size.width,
                                        height: fromView.frame.size.height)
            },completion:{finished in
                if finished {
                    snapShot?.removeFromSuperview()
                    pageView.isHidden = false
                    fromView.transform = CGAffineTransform.identity
                    transitionContext.completeTransition(true)
                }
            })
        }
    }
    
    func collectionTransition(fromViewController: UIViewController, toViewController: UIViewController, transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        containerView.backgroundColor = UIColor.white
        let animationScale = (screenWidth-40)/gridWidth

        if presenting {
            let toView = toViewController.view!
            containerView.addSubview(toView)
            toView.isHidden = true
            
            let waterFallView = (toViewController as! NTTransitionProtocol).transitionCollectionView()!
            let pageView = (fromViewController as! NTTransitionProtocol).transitionCollectionView()!
            waterFallView.layoutIfNeeded()
            let indexPath = pageView.fromPageIndexPath()
            
            var gridView: MainCollectionViewCell?
            let tag = ((settings.getCategory()+1) * 10000) + indexPath.row

            if let gridViewTemp = waterFallView.cellForItem(at: indexPath) as? MainCollectionViewCell {
                gridView = gridViewTemp
            } else if let gridViewTemp = waterFallView.viewWithTag(tag) as? MainCollectionViewCell {
                gridView = gridViewTemp
            }
            
            if let gridView = gridView {
                let leftUpperPoint = gridView.convert(CGPoint(x: gridView.gifView.frame.origin.x, y: gridView.gifView.frame.origin.y), to: toViewController.view)
                
                let snapShot = gridView.snapShotForTransition()
                snapShot?.transform = CGAffineTransform(scaleX: animationScale, y: animationScale)
                let pullOffsetY = (fromViewController as! NTHorizontalPageViewControllerProtocol).pageViewCellScrollViewContentOffset().y
                let offsetY : CGFloat = 84
                snapShot?.origin(CGPoint(x: 20, y: -pullOffsetY+offsetY))
                containerView.addSubview(snapShot!)
                
                toView.isHidden = false
                toView.alpha = 0
                toView.transform = (snapShot?.transform)!
                toView.frame = CGRect(x: -(leftUpperPoint.x * animationScale),y: -((leftUpperPoint.y-offsetY) * animationScale+pullOffsetY+offsetY),
                                      width: toView.frame.size.width, height: toView.frame.size.height)
                let whiteViewContainer = UIView(frame: screenBounds)
                whiteViewContainer.backgroundColor = UIColor.white
                containerView.addSubview(snapShot!)
                containerView.insertSubview(whiteViewContainer, belowSubview: toView)
                
                UIView.animate(withDuration: animationDuration, animations: {
                    snapShot?.transform = CGAffineTransform.identity
                    snapShot?.frame = CGRect(x: leftUpperPoint.x, y: leftUpperPoint.y, width: (snapShot?.frame.size.width)!, height: (snapShot?.frame.size.height)!)
                    toView.transform = CGAffineTransform.identity
                    toView.frame = CGRect(x: 0, y: 0, width: toView.frame.size.width, height: toView.frame.size.height);
                    toView.alpha = 1
                }, completion:{finished in
                    if finished {
                        snapShot?.removeFromSuperview()
                        whiteViewContainer.removeFromSuperview()
                        transitionContext.completeTransition(true)
                    }
                })
            } else {
                toView.isHidden = false
                toView.alpha = 0
                toView.frame = CGRect(x: 0, y: 0, width: toView.frame.size.width, height: toView.frame.size.height)
                
                UIView.animate(withDuration: animationDuration, animations: {
                    toView.alpha = 1
                    
                }, completion:{finished in
                    if finished {
                        transitionContext.completeTransition(true)
                        
                    }
                })
            }
        } else {
            let fromView = fromViewController.view!
            let toView = toViewController.view
            
            let waterFallView : UICollectionView = (fromViewController as! NTTransitionProtocol).transitionCollectionView()
            let pageView : UICollectionView = (toViewController as! NTTransitionProtocol).transitionCollectionView()
            
            containerView.addSubview(fromView)
            containerView.addSubview(toView!)
            
            let indexPath = waterFallView.toIndexPath()
            let gridView = waterFallView.cellForItem(at: indexPath)
            
            let leftUpperPoint = gridView!.convert(CGPoint(x: 0, y: 0), to: nil)
            pageView.isHidden = true
            pageView.scrollToItem(at: indexPath as IndexPath, at:.centeredHorizontally, animated: false)
            
            var offsetY: CGFloat = 105
            
            if Device.version() == .iPhoneX {
                offsetY = 130
            }
            
            let offsetStatuBar : CGFloat = fromViewController.navigationController!.isNavigationBarHidden ? 0.0 : statubarHeight
            let snapShot = (gridView as! NTTansitionWaterfallGridViewProtocol).snapShotForTransition()
            containerView.addSubview(snapShot!)
            snapShot?.origin(leftUpperPoint)
            UIView.animate(withDuration: animationDuration, animations: {
                snapShot?.transform = CGAffineTransform(scaleX: animationScale,
                                                        y: animationScale)
                snapShot?.frame = CGRect(x: 20, y: offsetY, width: (snapShot?.frame.size.width)!, height: (snapShot?.frame.size.height)!)
                
                fromView.alpha = 0
                fromView.transform = (snapShot?.transform)!
                fromView.frame = CGRect(x: -(leftUpperPoint.x)*animationScale,
                                        y: -(leftUpperPoint.y-offsetStatuBar)*animationScale+offsetStatuBar,
                                        width: fromView.frame.size.width,
                                        height: fromView.frame.size.height)
            },completion:{finished in
                if finished {
                    snapShot?.removeFromSuperview()
                    pageView.isHidden = false
                    fromView.transform = CGAffineTransform.identity
                    transitionContext.completeTransition(true)
                }
            })
        }
    }

}
