//
//  MBSafariViewController.swift
//  MotionBook
//
//  Created by YiSeungyoun on 2017. 5. 17..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import Foundation
import SafariServices

enum PresentType {
    case modal
    case push
}

class MBSafariViewController {
    class func show(viewController: UIViewController, url: String, type: PresentType) {
        if let url = URL(string: url) {
            let safariViewController = SFSafariViewController(url:url)
            if #available(iOS 10.0, *) {
                safariViewController.preferredControlTintColor = UIColor(hexString: MainColor)
            }
            if type == .modal {
                safariViewController.modalPresentationStyle = .overFullScreen
                safariViewController.modalPresentationCapturesStatusBarAppearance = true
            }
            viewController.present(safariViewController, animated:true, completion:nil)
        }
    }
}
