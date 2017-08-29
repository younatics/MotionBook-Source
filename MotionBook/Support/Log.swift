//
//  Log.swift
//  MotionBook
//
//  Created by YiSeungyoun on 2017. 6. 8..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import Foundation
import Crashlytics

class Log {
    class func contentview(action: String, location: UIViewController?, id: String?) {
        guard let vc = location, let vcString = NSStringFromClass(vc.classForCoder).components(separatedBy: ".").last else { return }
        
        Answers.logContentView(withName: action,
                               contentType: vcString,
                               contentId: id ?? "",
            customAttributes: nil)
    }
    
    class func addToCart(price: NSDecimalNumber, action: String, location: UIViewController?, id: String?) {
        guard let vc = location, let vcString = NSStringFromClass(vc.classForCoder).components(separatedBy: ".").last else { return }

        Answers.logAddToCart(withPrice: price,
                             currency: "USD",
                             itemName: action,
                             itemType: vcString,
                             itemId: id ?? "",
            customAttributes: nil)
    }
    
    class func purchase(price: NSDecimalNumber, name: String, location: UIViewController?, id: String?) {
        guard let vc = location, let vcString = NSStringFromClass(vc.classForCoder).components(separatedBy: ".").last else { return }

        Answers.logPurchase(withPrice: price,
                            currency: "USD",
                            success: true,
                            itemName: name,
                            itemType: vcString,
                            itemId: id ?? "",
                            customAttributes: [:])

    }
    
    class func search(value: String) {
        Answers.logSearch(withQuery: value,
                          customAttributes: [:])
        
    }
    
    class func share(name: String, location: UIViewController?, id: String?) {
        guard let vc = location, let vcString = NSStringFromClass(vc.classForCoder).components(separatedBy: ".").last else { return }
        
        Answers.logShare(withMethod: "Detail Share", contentName: name, contentType: vcString, contentId: id ?? "", customAttributes: nil)
    }
    
    class func checkOut(price: NSDecimalNumber) {
        Answers.logStartCheckout(withPrice: price, currency: "USD", itemCount: 1, customAttributes: nil)
    }
}
