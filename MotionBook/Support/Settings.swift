//
//  Settings.swift
//  motion-book
//
//  Created by YiSeungyoun on 2017. 2. 11..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import Foundation

class Settings: NSObject {
    
    var pref: UserDefaults!
    
    override init() {
        pref = UserDefaults.standard
    }
    
    func setFullyDownloaded(value: Bool) {
        pref.set(value, forKey: "fullyDownloaded")
    }
    
    func getFullyDownloaded() -> Bool {
        guard let fullyDownloaded = pref.object(forKey: "fullyDownloaded") as? Bool else { return false }
        return fullyDownloaded
    }
        
    func setDate(value: Date) {
        pref.set(value, forKey: "date")
    }

    func getDate() -> Date? {
        guard let date = pref.object(forKey: "date") as? Date else { return nil }
        return date
    }
    
    func setSortKey(value: Int) {
        pref.set(value, forKey: "SortKey")
    }
    
    func getSortKey() -> Int {
        guard let sortKey = pref.object(forKey: "SortKey") as? Int else { return 0 }
        return sortKey
    }
    
    func setCategory(value: Int) {
        pref.set(value, forKey: "Category")
    }
    
    func getCategory() -> Int {
        guard let sortKey = pref.object(forKey: "Category") as? Int else { return 0 }
        return sortKey
    }

    func setOpenSourceIntroViewShown(value: Bool) {
        pref.set(value, forKey: "OpenSourceIntroView")
    }
    
    func getOpenSourceIntroViewShown() -> Bool {
        guard let sortKey = pref.object(forKey: "OpenSourceIntroView") as? Bool else { return false }
        return sortKey
    }
    
    func setInappPurchased(value: Bool) {
        pref.set(value, forKey: "InappPurchased")
    }

    func getInappPurchased() -> Bool {
        guard let sortKey = pref.object(forKey: "InappPurchased") as? Bool else { return false }
        return sortKey
    }
    
    func setShortCutKey(value: Int) {
        pref.set(value, forKey: "ShortCutKey")
    }
    
    func removeShorCutKey() {
        pref.removeObject(forKey: "ShortCutKey")
    }
    
    func getShortCutKey() -> Int? {
        guard let shortCutKey = pref.object(forKey: "ShortCutKey") as? Int else { return nil }
        return shortCutKey
    }
}
