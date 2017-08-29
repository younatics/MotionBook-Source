//
//  NetworkActivityIndicatorManager.swift
//  MotionBook
//
//  Created by YiSeungyoun on 2017. 5. 9..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import Foundation
import UIKit

class NetworkActivityIndicatorManager: NSObject {
    
    private static var loadingCount = 0
    
    class func networkOperationStarted() {
        
        #if os(iOS)
            if loadingCount == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            loadingCount += 1
        #endif
    }
    
    class func networkOperationFinished() {
        #if os(iOS)
            if loadingCount > 0 {
                loadingCount -= 1
            }
            if loadingCount == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        #endif
    }
}
