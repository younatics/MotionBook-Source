//
//  OpenSourceManager.swift
//  MotionBook
//
//  Created by YiSeungyoun on 2017. 5. 15..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import SnapKit

class OpenSourceManager {
    class func getViewControllerWith(title: String) -> UIViewController? {
        switch title {
        case "CRToast":
            return CRToastController(nibName: "CRToastController", bundle: nil)

        case "expanding-collection":
            let storyboard = UIStoryboard(name: "ExpandingCollection", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "ExpandingCollection")
            
        case "Hero":
            let storyboard = UIStoryboard(name: "Hero", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "Hero")
            
        case "YNDropDownMenu":
            let storyboard = UIStoryboard(name: "YNDropDownMenu", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "YNDropDownMenu")
            
        case "NVActivityIndicatorView":
            return NVActivityIndicatorViewController()
            
        case "circle-menu":
            let storyboard = UIStoryboard(name: "circle-menu", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "CircleMenuViewController")
            
        case "SideMenu":
            let storyboard = UIStoryboard(name: "SideMenu", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "SideMenuMainViewController")
            
        case "animated-tab-bar":
            let storyboard = UIStoryboard(name: "animated-tab-bar", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "animated-tab-bar")
            
        case "Pastel":
            let storyboard = UIStoryboard(name: "Pastel", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "Pastel")
            
        case "JTMaterialTransition":
            let storyboard = UIStoryboard(name: "JTMaterialTransition", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "JTMaterialTransition")

        case "AnimatedCollectionViewLayout":
            let storyboard = UIStoryboard(name: "AnimatedCollectionViewLayout", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "AnimatedCollectionViewLayout")
            
        case "preview-transition":
            let storyboard = UIStoryboard(name: "preview-transition", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "PTDemoTableViewController")

        case "YNExpandableCell":
            let storyboard = UIStoryboard(name: "YNExpandableCell", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "YNExpandableCell")
            
        case "Koloda":
            let storyboard = UIStoryboard(name: "Koloda", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "Koloda")

        case "TKRubberIndicator":
            let storyboard = UIStoryboard(name: "TKRubberIndicator", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "TKRubberIndicator")

        case "SweetAlert-iOS":
            let storyboard = UIStoryboard(name: "SweetAlert", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "SweetAlert")

        case "PopupDialog":
            let storyboard = UIStoryboard(name: "PopupDialog", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "PopupDialog")

        case "MIBlurPopup":
            let storyboard = UIStoryboard(name: "MIBlurPopup", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "MIBlurPopup")
            
        case "folding-cell":
            let storyboard = UIStoryboard(name: "folding-cell", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "folding-cell")
            
        case "Pull-to-Refresh.Rentals-iOS":
            let storyboard = UIStoryboard(name: "YALRentalPullToRefresh", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "YALRentalPullToRefresh")

        case "Spring":
            let storyboard = UIStoryboard(name: "Spring", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "Spring")
            
        case "RQShineLabel":
            let storyboard = UIStoryboard(name: "RQShineLabel", bundle: nil)
            return storyboard.instantiateViewController(withIdentifier: "RQShineLabel")

        case "NotificationBanner":
            return NotificationBannerViewController()

        default:
            break
        }
        return nil
    }
    
    class func getWhyNotWith(title: String) -> String? {
        switch title {
        case "FLAnimatedImage":
            return "Only support iPad in example"
            
        case "GuillotineMenu":
            return "Conflict with MotionBook view hierachy"
            
        case "Side-Menu.iOS":
            return "Conflict with MotionBook view hierachy"
            
        case "SlideMenuControllerSwift":
            return "Conflict with MotionBook view hierachy"
                        
        case "Stellar":
            return "Conflict with UIAlertViewcontroller"

        case "TKSubmitTransition":
            return "Not support Swift 3"
            
        case "Highlighter":
            return "Used in MotionBook search section"
            
        case "YNSearch":
            return "Used in MotionBook search section"
            
        case "PinterestSwift":
            return "Used in MotionBook main section"

        case "CKWaveCollectionViewTransition":
            return "Conflict with MotionBook transition"

        case "TKSwarmAlert":
            return "Example is not look same with GIF"

        case "Presentation":
            return "Used in MotionBook Download section"

        case "LTMorphingLabel":
            return "Used in MotionBook Download bubble"

        default:
            break
        }
        return nil

    }
}

