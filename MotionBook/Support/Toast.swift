//
//  Toast.swift
//  motion-book
//
//  Created by YiSeungyoun on 2017. 2. 20..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import Foundation
import NotificationBannerSwift

class Toast: NSObject {
    class func showToast(text: String) {
        let banner = NotificationBanner(title: "MotionBook", subtitle: text, leftView: nil, rightView: nil, style: .none, colors: MotionBookBannerColors())
        banner.show()
    }
    
    class func showToast(title: String, subtitle: String) {
        let banner = NotificationBanner(title: title, subtitle: subtitle, leftView: nil, rightView: nil, style: .none, colors: MotionBookBannerColors())
        banner.show()
    }
}
class MotionBookBannerColors: BannerColorsProtocol {
    func color(for style: BannerStyle) -> UIColor {
        switch style {
        case .danger:   return UIColor(red:0.90, green:0.31, blue:0.26, alpha:1.00)
        case .info:     return UIColor(red:0.23, green:0.60, blue:0.85, alpha:1.00)
        case .none:     return UIColor(hexString: MainColor)
        case .success:  return UIColor(red:0.22, green:0.80, blue:0.46, alpha:1.00)
        case .warning:  return UIColor(red:1.00, green:0.66, blue:0.16, alpha:1.00)
        }
    }
    
}
