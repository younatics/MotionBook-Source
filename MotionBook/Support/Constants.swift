//
//  Constants.swift
//  MotionBook
//
//  Created by YiSeungyoun on 2017. 5. 2..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import Foundation
import Device

let MainColor = "EE165B"
let GrayColor = "A6AEB7"
let LineColor = "D9D8DF"
let TitleColor = "5C6774"
let E1E4E8 = "E1E4E8"

let isTest = false

var DynamicNavigationHeight: CGFloat {
    if Device.version() == .iPhoneX || isTest {
        return 80
    } else {
        return 64
    }
}

var DynamicCenterOffset: CGFloat {
    if Device.version() == .iPhoneX || isTest {
        return 16
    } else {
        return 10
    }
}

var DynamicOffset: CGFloat {
    if Device.version() == .iPhoneX || isTest {
        return 30
    } else {
        return 20
    }
}

var DynamicBottomHeight: CGFloat {
    if Device.version() == .iPhoneX || isTest {
        return 75
    } else {
        return 50
    }
}

var DynamicPurchaseCloseButtonOffset: CGFloat {
    if Device.version() == .iPhoneX || isTest {
        return 40
    } else {
        return 32
    }
}

var DynamicIntroTopOffset: CGFloat {
    if Device.version() == .iPhoneX || isTest {
        return 50
    } else {
        return 0
    }
}

var DynamicIntroBottomOffset: CGFloat {
    if Device.version() == .iPhoneX || isTest {
        return 79
    } else {
        return 49
    }
}



let GradationColors = [UIColor(hexString:"E17048"),
                       UIColor(hexString:"EE165B"),
                       UIColor(hexString:"E74551"),
                       UIColor(hexString:"EE165B")]
