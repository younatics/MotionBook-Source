//
//  ReviewController.swift
//  MotionBook
//
//  Created by YiSeungyoun on 2017. 11. 19..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import Foundation
import StoreKit

class ReviewController {
    class func show() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            if let url = URL(string: "https://appsto.re/kr/8yv1hb.i"),
                UIApplication.shared.canOpenURL(url){
                UIApplication.shared.openURL(url)
            }
        }
    }
}
